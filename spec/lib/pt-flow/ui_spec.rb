require 'spec_helper'

describe PT::Flow::UI do

  let(:endpoint) { "http://www.pivotaltracker.com/services/v3" }
  let(:prompt) { double('HighLine') }

  before(:all) do
    dummy_path = 'spec/fixtures/dummy'
    Dir.rmdir(dummy_path)
    Dir.mkdir(dummy_path)
    Dir.chdir(dummy_path)
    system('git init .')
  end

  before do
    HighLine.stub(new: prompt)
    stub_request(:get, /projects$/).to_return(body: fixture_file('projects.xml'))
    stub_request(:get, /stories\?/).to_return(body: fixture_file('stories.xml'))
    stub_request(:any, /stories\/\d+/).to_return(body: fixture_file('story.xml'))
  end

  describe '#start' do
    context 'given an unestimated story' do
      it "shows lists of stories - choosing one asks you to estimate, starts/assigns the story on pt and checks out a new branch." do
        prompt.should_receive(:ask).with("Please select a task to start working on (1-14, 'q' to exit)".bold).and_return('2')
        prompt.should_receive(:ask).with("How many points do you estimate for it? (0,1,2,3)".bold).and_return('3')

        PT::Flow::UI.new %w{ start }

        WebMock.should have_requested(:get, "#{endpoint}/projects/102622/stories?filter=current_state:unscheduled,unstarted,started")
        WebMock.should have_requested(:put, "#{endpoint}/projects/102622/stories/4459994").with(body: /<estimate>3<\/estimate>/)
        WebMock.should have_requested(:put, "#{endpoint}/projects/102622/stories/4459994").with(body: /<owned_by>Jon Mischo<\/owned_by>/)
        WebMock.should have_requested(:put, "#{endpoint}/projects/102622/stories/4459994").with(body: /<current_state>started<\/current_state>/)
      end
    end

    context 'given an already estimated story' do
      it "does not prompt to estimate" do
        prompt.should_receive(:ask).once.with("Please select a task to start working on (1-14, 'q' to exit)".bold).and_return('3')

        PT::Flow::UI.new %w{ start }
      end
    end
  end

end
