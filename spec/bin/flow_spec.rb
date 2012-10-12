require 'spec_helper'

def should_call(method, path, options = {})
  url = "http://www.pivotaltracker.com/services/v3/#{path}"
  stub = stub_request(method, url)
  stub.with(body: /#{options[:body]}/) if options[:body]
  stub.to_return(body: fixture(path))

  WebMock.should have_requested(method, url)#.with(body: /#{options[:body]}/)
end

def fixture(url)
  name = url.gsub('/','-').gsub(':','=')
  File.new File.join(File.dirname(__FILE__), '..', 'fixtures', 'webmock', "#{name}.xml")
end

describe 'flow binary' do

  let(:prompt) { double('HighLine') }

  before do
    HighLine.stub(new: prompt)
  end

  describe '#start' do
    context 'given an unestimated task' do
      it "shows lists of tasks - choosing one asks you to estimate the task and starts/assigns the task on pt and checks out a new branch." do
        should_call(:get, 'projects')
        should_call(:get, 'projects/102622/stories?filter=current_state:unscheduled,unstarted,started')

        prompt.should_receive(:ask).with("Please select a task to start working on (1-14, 'q' to exit)".bold).and_return('2')
        should_call(:get, 'projects/102622/stories/4459994')

        prompt.should_receive(:ask).with("How many points do you estimate for it? (0,1,2,3)".bold).and_return('3')
        should_call(:put, 'projects/102622/stories/4459994', body: '<estimate>3</estimate>')

        should_call(:put, 'projects/102622/stories/4459994', body: '<owned_by>Jon Mischo</owned_by>')
        should_call(:put, 'projects/102622/stories/4459994', body: '<current_state>started</current_state>')

        PT::Flow::UI.new %w{ start }
      end
    end
  end

end
