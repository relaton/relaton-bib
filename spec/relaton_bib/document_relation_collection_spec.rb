# RSpec.describe RelatonBib::DocRelationCollection do
#   context "instance" do
#     subject do
#       RelatonBib::DocRelationCollection.new(
#         [
#           RelatonBib::DocumentRelation.new(
#             type: "updates",
#             bibitem: RelatonBib::BibliographicItem.new(
#               formattedref: RelatonBib::FormattedRef.new(content: "realtion1"),
#             ),
#           ),
#           RelatonBib::DocumentRelation.new(
#             type: "obsoletes", bibitem: "realtion1",
#           ),
#         ],
#       )
#     end

#     it "returns one replace" do
#       expect(subject.replaces.size).to eq 1
#     end
#   end
# end
