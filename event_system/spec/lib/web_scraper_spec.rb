require 'spec_helper'

describe WebScraper do
  let(:file) { File.open("temperatures.html", "r") }

  it "scrapes temperature given a nodeset" do
    doc = Nokogiri::HTML(file)
    temp = WebScraper.scrape_temperatures(doc)
    expect(temp[Date.today]).to eq ({"high"=> "34", "low"=> "21"})
    expect(temp.size).to eq(5)
  end

  it "gets detailed descrition of forecast" do
    doc = Nokogiri::HTML(file)
    description = WebScraper.detailed_scrape(doc)
    expect(description[Date.today]["detail_afternoon"]).to match(/Sunny, with a high near/)
  end
end