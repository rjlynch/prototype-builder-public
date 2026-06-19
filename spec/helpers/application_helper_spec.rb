require "rails_helper"

RSpec.describe ApplicationHelper, type: :helper do
  describe "#tab_window" do
    let(:items) { (1..20).to_a }

    it "shows everything with no arrows when it all fits" do
      window = helper.tab_window([ 1, 2, 3 ], 2, per: 8)

      expect(window.items).to eq([ 1, 2, 3 ])
      expect(window.previous).to be_nil
      expect(window.next).to be_nil
    end

    it "clamps to the start with only a next arrow near the front" do
      window = helper.tab_window(items, 1, per: 8)

      expect(window.items).to eq((1..8).to_a)
      expect(window.previous).to be_nil
      expect(window.next).to eq(9) # the next item past the window
    end

    it "slides to keep the current item centred, with both arrows" do
      window = helper.tab_window(items, 9, per: 8)

      expect(window.items).to eq((6..13).to_a) # 9 sits 4th of 8
      expect(window.previous).to eq(5)
      expect(window.next).to eq(14)
    end

    it "clamps to the end with only a previous arrow near the back" do
      window = helper.tab_window(items, 20, per: 8)

      expect(window.items).to eq((13..20).to_a)
      expect(window.previous).to eq(12)
      expect(window.next).to be_nil
    end

    it "honours a custom window size, keeping current centred" do
      window = helper.tab_window((1..7).to_a, 4, per: 3)

      expect(window.items).to eq([ 3, 4, 5 ]) # 4 centred in a window of 3
      expect(window.previous).to eq(2)
      expect(window.next).to eq(6)
    end

    it "falls back to the start when current isn't in the list" do
      window = helper.tab_window(items, 999, per: 8)

      expect(window.items).to eq((1..8).to_a)
      expect(window.previous).to be_nil
    end
  end
end
