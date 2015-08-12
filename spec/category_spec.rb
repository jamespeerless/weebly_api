require 'spec_helper'

describe WeeblyApi::Category, faraday: true do
  subject { WeeblyApi::Category.new({"id" => 123, "parentId" => 456}, client: client) }

  describe "#sub_categories" do
    it "sends the request to the CategoryApi" do
      expect(client.categories).to receive(:all).with(parent: 123)
      subject.sub_categories
    end

    it "is memoized" do
      subject.sub_categories
      expect(client.categories).to_not receive(:all)
      subject.sub_categories
    end
  end

  describe "#parent" do
    it "sends the request for the parent to the CategoryApi" do
      expect(client.categories).to receive(:find).with(456)
      subject.parent
    end

    context "without a parent" do
      subject { WeeblyApi::Category.new({"id" => 123}) }

      it "returns nil" do
        expect(client.categories).to_not receive(:find)
        subject.parent.should be_nil
      end
    end
  end
end