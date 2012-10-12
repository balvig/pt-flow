require 'spec_helper'

def fixture_file(name)
  File.new File.join(File.dirname(__FILE__), '..', '..', 'fixtures', 'webmock', name)
end

describe PT::Flow::UI do

  let(:endpoint) { "http://www.pivotaltracker.com/services/v3" }
  let(:prompt) { double('HighLine') }

  before do
    HighLine.stub(new: prompt)
    stub_request(:get, /projects$/).to_return(body: fixture_file('projects.xml'))
    stub_request(:get, /stories\?/).to_return(body: fixture_file('stories.xml'))
    stub_request(:any, /stories\/\d+/).to_return(body: fixture_file('story.xml'))
  end

  describe '#start' do
    context 'given an unestimated task' do
      it "shows lists of tasks - choosing one asks you to estimate the task and starts/assigns the task on pt and checks out a new branch." do

        prompt.should_receive(:ask).with("Please select a task to start working on (1-14, 'q' to exit)".bold).and_return('2')
        prompt.should_receive(:ask).with("How many points do you estimate for it? (0,1,2,3)".bold).and_return('3')

        PT::Flow::UI.new %w{ start }

        WebMock.should have_requested(:get, "#{endpoint}/projects/102622/stories?filter=current_state:unscheduled,unstarted,started")
        WebMock.should have_requested(:put, "#{endpoint}/projects/102622/stories/4459994").with(body: /<estimate>3<\/estimate>/)
        WebMock.should have_requested(:put, "#{endpoint}/projects/102622/stories/4459994").with(body: /<owned_by>Jon Mischo<\/owned_by>/)
        WebMock.should have_requested(:put, "#{endpoint}/projects/102622/stories/4459994").with(body: /<current_state>started<\/current_state>/)

      end
    end
  end

end
