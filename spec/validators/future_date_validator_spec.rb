require 'rails_helper'

class Validator
  include ActiveModel::Validations

  attr_accessor :date

  validates :date, future_date: true
end


describe FutureDateValidator do 
  subject { Validator.new }

  context "when data is before current date" do
    before {
      subject.date = 1.day.ago
    }

    it "should be invalid" do 
      expect(subject.valid?).to be_falsey
    end

    it "should add error on model" do 
      subject.valid?
      expect(subject.errors.keys).to include(:date)
    end
  end

  context "when data is equal current data" do
    before {
      subject.date = Time.zone.now
    }

    it "should be invalid" do
      expect(subject.valid?).to be_falsey
    end

    it "should add error on model" do 
      subject.valid?
      expect(subject.errors.keys).to include(:date)
    end
  end

  context "when data is greater than current data" do
    before {
      subject.date = Time.zone.now + 1.day
    }

    it "should be valid" do
      expect(subject.valid?).to be_truthy
    end

  end
end

