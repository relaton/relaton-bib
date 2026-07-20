require "open3"
require "tempfile"

# Regression coverage for issue #120: the circular require between
# organization_type.rb and subdivision.rb, resolved by converting internal
# require_relative to Ruby autoload. The "circular require considered harmful"
# warning only surfaces under warnings, so these specs assert the structural and
# behavioural invariants that are meaningful on every supported Ruby, plus a
# subprocess guard for the warning itself.
describe "Ruby autoload wiring (issue #120)" do
  def gem_root
    File.expand_path("../../..", __dir__)
  end

  # Run a Ruby snippet in a fresh process under bundler, from the gem root.
  # The snippet is written to a temp file rather than passed via `-e` so that
  # multi-line code with embedded quotes runs identically on POSIX and Windows
  # (Windows mangles newlines/quotes when reconstructing an `-e` argv element).
  def run_ruby(code, warn: false)
    flags = warn ? ["-W2"] : []
    Tempfile.create(["autoload_check", ".rb"]) do |file|
      file.write(code)
      file.flush
      cmd = ["bundle", "exec", "ruby", *flags, file.path]
      Bundler.with_unbundled_env do
        Open3.capture3({ "BUNDLE_GEMFILE" => File.join(gem_root, "Gemfile") },
                       *cmd, chdir: gem_root)
      end
    end
  end

  it "has no in-hook require in OrganizationType (the cycle culprit)" do
    src = File.read(File.join(gem_root,
                              "lib/relaton/bib/model/organization_type.rb"))
    expect(src).not_to match(/^\s*require(_relative)?\b/)
  end

  it "defines Relation as a self-contained Lutaml serializable" do
    expect(Relaton::Bib::Relation.ancestors)
      .to include(Lutaml::Model::Serializable)
  end

  it "configures the nokogiri XML adapter regardless of load order" do
    expect(Lutaml::Model::Config.xml_adapter_type).to eq(:nokogiri)
  end

  it "round-trips an organization with a nested subdivision" do
    xml = <<~XML.strip
      <organization>
        <name>International Organization for Standardization</name>
        <subdivision type="technical-committee" subtype="Type">
          <name>Editorial group</name>
        </subdivision>
        <abbreviation>ISO</abbreviation>
      </organization>
    XML
    org = Relaton::Bib::Organization.from_xml(xml)
    expect(org.subdivision.first.name.first.content).to eq("Editorial group")
    expect(org.subdivision.first.type).to eq("technical-committee")
    expect(org.to_xml).to be_equivalent_to(xml)
  end

  it "round-trips a standalone subdivision" do
    xml = %(<subdivision type="tc"><name>Editorial group</name></subdivision>)
    sub = Relaton::Bib::Subdivision.from_xml(xml)
    expect(sub).to be_a(Relaton::Bib::Subdivision)
    expect(sub.class.ancestors).to include(Relaton::Bib::OrganizationType)
    expect(sub.to_xml).to be_equivalent_to(xml)
  end

  it "loads with Subdivision referenced before Organization" do
    code = <<~RUBY
      require "relaton/bib"
      Relaton::Bib::Subdivision
        .from_xml("<subdivision><name>x</name></subdivision>")
      print "OK"
    RUBY
    out, err, status = run_ruby(code)
    expect(status).to be_success, "stderr: #{err}"
    expect(out.strip).to eq("OK")
  end

  it "loads with Organization referenced before Subdivision" do
    code = <<~RUBY
      require "relaton/bib"
      Relaton::Bib::Organization
        .from_xml("<organization><name>x</name></organization>")
      print "OK"
    RUBY
    out, err, status = run_ruby(code)
    expect(status).to be_success, "stderr: #{err}"
    expect(out.strip).to eq("OK")
  end

  it "emits no relaton-bib 'circular require' warning under warnings" do
    code = <<~RUBY
      require "relaton/bib"
      Relaton::Bib::Organization
      Relaton::Bib::Subdivision
    RUBY
    _out, err, status = run_ruby(code, warn: true)
    expect(status).to be_success, "stderr: #{err}"
    # Only relaton-bib's own files matter here; unrelated third-party gems
    # (e.g. lutaml-model) may emit their own circular-require warnings.
    offending = err.lines.grep(/circular require/).grep(%r{relaton/bib})
    expect(offending).to be_empty, offending.join
  end
end
