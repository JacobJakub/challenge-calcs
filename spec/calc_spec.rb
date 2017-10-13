# Feel free to add some new tests. The structure of models are given and required as it is.
require 'spec_helper'
require './lib/calculator'

describe 'Calculations' do

  # Questions
  # gender: [male, female]
  # age: [young, middle, old]
  # colour: [red, blue]

  # Audiences
  let(:red_likers_audience) { {must: [{colour: [:red]}]} }
  let(:female_or_not_old_audience) { {should: [{gender: [:female]}, {age: [:young, :middle]}]} }
  let(:red_and_blue_audience) { {must: [{colour: [:red]}, {colour: [:blue]}]} }

  let(:respondents) do
    [
      { id: 'john', weighting: 1100, answers: { gender: [:male], age: [:young], colour: [:red], likes: [:ios, :android, :icecream] } },
      { id: 'petr', weighting: 1100, answers: { gender: [:male], age: [:old], colour: [:red], likes: [:ios, :myos, :panckaes] } },
      { id: 'steve', weighting: 1100, answers: { gender: [:male], age: [:middle], colour: [:blue], likes: [:nokia, :android, :arduino, :horses] } },
      { id: 'rachel', weighting: 1000, answers: { gender: [:female], age: [:young], colour: [:blue], likes: [:alcatel, :ios, :android, :nokia, :reddit] } },
      { id: 'susan', weighting: 1000, answers: { gender: [:female], age: [:old], colour: [:red], likes: [:ios, :nokia, :htc, :android, :facebook] } },
      { id: 'cate', weighting: 1000, answers: { gender: [:female], age: [:middle], colour: [:blue], likes: [:htc, :ios, :nokia, :selfies] } }
    ]
  end

  before do
    EsHelpers.create_index
    EsHelpers.seed_respondents(respondents)
  end

  after do
    EsHelpers.destroy_index
  end

  subject { Calculator.new(question: question, audience: audience).result }
  let(:question) { nil }
  let(:audience) { nil }

  context "likes question" do
    let(:question) { :likes }

    it 'should return correct result' do
      expect(subject).to match_array([
        {:option=>"ios", :responses_count=>5, :weighted=>5200, :percentage=>82.54},
        {:option=>"android", :responses_count=>4, :weighted=>4200, :percentage=>66.67},
        {:option=>"nokia", :responses_count=>4, :weighted=>4100, :percentage=>65.08},
        {:option=>"htc", :responses_count=>2, :weighted=>2000, :percentage=>31.75},
        {:option=>"alcatel", :responses_count=>1, :weighted=>1000, :percentage=>15.87},
        {:option=>"arduino", :responses_count=>1, :weighted=>1100, :percentage=>17.46},
        {:option=>"facebook", :responses_count=>1, :weighted=>1000, :percentage=>15.87},
        {:option=>"horses", :responses_count=>1, :weighted=>1100, :percentage=>17.46},
        {:option=>"icecream", :responses_count=>1, :weighted=>1100, :percentage=>17.46},
        {:option=>"myos", :responses_count=>1, :weighted=>1100, :percentage=>17.46},
        {:option=>"panckaes", :responses_count=>1, :weighted=>1100, :percentage=>17.46},
        {:option=>"reddit", :responses_count=>1, :weighted=>1000, :percentage=>15.87},
        {:option=>"selfies", :responses_count=>1, :weighted=>1000, :percentage=>15.87}
      ])
    end

    context 'with female or not old audience' do
      let(:audience) { female_or_not_old_audience }

      it 'should return correct result' do
        expect(subject).to match_array([
          {:option=>"android", :responses_count=>4, :weighted=>4200, :percentage=>80.77},
          {:option=>"ios", :responses_count=>4, :weighted=>4100, :percentage=>78.85},
          {:option=>"nokia", :responses_count=>4, :weighted=>4100, :percentage=>78.85},
          {:option=>"htc", :responses_count=>2, :weighted=>2000, :percentage=>38.46},
          {:option=>"alcatel", :responses_count=>1, :weighted=>1000, :percentage=>19.23},
          {:option=>"arduino", :responses_count=>1, :weighted=>1100, :percentage=>21.15},
          {:option=>"facebook", :responses_count=>1, :weighted=>1000, :percentage=>19.23},
          {:option=>"horses", :responses_count=>1, :weighted=>1100, :percentage=>21.15},
          {:option=>"icecream", :responses_count=>1, :weighted=>1100, :percentage=>21.15},
          {:option=>"reddit", :responses_count=>1, :weighted=>1000, :percentage=>19.23},
          {:option=>"selfies", :responses_count=>1, :weighted=>1000, :percentage=>19.23},
          {:option=>"myos", :responses_count=>0, :weighted=>0, :percentage=>0.0},
          {:option=>"panckaes", :responses_count=>0, :weighted=>0, :percentage=>0.0}
        ])
      end
    end
  end

  context "gender question" do
    let(:question) { :gender }

    it 'has correct responses count for male' do
      # This is warming green test
      expect(subject.detect{|o| o[:option] == 'male'}[:responses_count]).to eq(3)
    end

    it 'should return correct result' do
      # male: john, peter, steve
      # female: rachel, susan, cate
      expect(subject).to match_array([
        {
          option: 'male',
          responses_count: 3,
          weighted: 3300,
          percentage: 52.38
        },
        {
          option: 'female',
          responses_count: 3,
          weighted: 3000,
          percentage: 47.62
        }
      ])
    end

    context "with red likers audience" do
      let(:audience) { red_likers_audience }

      # red: john, peter, susan
      #   male: john, peter
      #   female: susan
      it 'should return correct result' do
        expect(subject).to match_array([
          {
            option: 'male',
            responses_count: 2,
            weighted: 2200,
            percentage: 68.75
          },
          {
            option: 'female',
            responses_count: 1,
            weighted: 1000,
            percentage: 31.25
          }
        ])
      end
    end # with red likers audience

    context "with red and blue likers audience" do
      let(:audience) { red_and_blue_audience }

      it 'should return correct result' do
        expect(subject).to match_array([
          {
            option: 'male',
            responses_count: 0,
            weighted: 0,
            percentage: 0
          },
          {
            option: 'female',
            responses_count: 0,
            weighted: 0,
            percentage: 0
          }
        ])
      end
    end # with red and blue likers audience
  end # gender question

  context "colour question" do
    let(:question) { :colour }

    it 'should return correct result' do
      expect(subject).to match_array([
        {
          option: 'blue',
          responses_count: 3,
          weighted: 3100,
          percentage: 49.21
        },
        {
          option: 'red',
          responses_count: 3,
          weighted: 3200,
          percentage: 50.79
        }
      ])
    end

    context "with female or not old audience" do
      let(:audience) { female_or_not_old_audience }

      it 'should return correct result' do
        expect(subject).to match_array([
          {
            option: 'blue',
            responses_count: 3,
            weighted: 3100,
            percentage: 59.62
          },
          {
            option: 'red',
            responses_count: 2,
            weighted: 2100,
            percentage: 40.38
          }
        ])
      end
    end

    context "with female || (red && old) audience" do
      let(:female_or_red_old_audience) { {
        should: [
          {gender: [:female]},
          {must: [{colour: [:red]}, {age: [:old]}]}
        ]
      } }
      let(:audience) { female_or_red_old_audience }

      it 'should return correct result' do
        expect(subject).to match_array([
          {
            option: 'blue',
            responses_count: 2,
            weighted: 2000,
            percentage: 48.78
          },
          {
            option: 'red',
            responses_count: 2,
            weighted: 2100,
            percentage: 51.22
          }
        ])
      end
    end
  end
end
