require "rails_helper"

RSpec.describe ApplicationHelper, type: :helper do
  describe "#tab_window" do
    let(:items) { (1..20).to_a }

    it "shows everything with no arrows when it all fits in one block" do
      window = helper.tab_window([ 1, 2, 3 ], 2, per: 8)

      expect(window.items).to eq([ 1, 2, 3 ])
      expect(window.previous).to be_nil
      expect(window.next).to be_nil
    end

    it "offers a next arrow from the first block" do
      window = helper.tab_window(items, 1, per: 8)

      expect(window.items).to eq((1..8).to_a)
      expect(window.previous).to be_nil
      expect(window.next).to eq(9) # first page of the next block
    end

    it "offers both arrows from a middle block" do
      window = helper.tab_window(items, 9, per: 8)

      expect(window.items).to eq((9..16).to_a)
      expect(window.previous).to eq(8)  # last page of the previous block
      expect(window.next).to eq(17)     # first page of the next block
    end

    it "offers only a previous arrow from the last, partial block" do
      window = helper.tab_window(items, 17, per: 8)

      expect(window.items).to eq([ 17, 18, 19, 20 ])
      expect(window.previous).to eq(16)
      expect(window.next).to be_nil
    end

    it "honours a custom block size" do
      window = helper.tab_window((1..7).to_a, 4, per: 3)

      expect(window.items).to eq([ 4, 5, 6 ]) # block index 1: items 4,5,6
      expect(window.previous).to eq(3)
      expect(window.next).to eq(7)
    end

    it "falls back to the first block when current isn't in the list" do
      window = helper.tab_window(items, 999, per: 8)

      expect(window.items).to eq((1..8).to_a)
      expect(window.previous).to be_nil
    end
  end
end
