require 'spec_helper'

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
    context 'given an unestimated story' do
      it "shows lists of stories - choosing one asks you to estimate, starts/assigns the story on pt and checks out a new branch." do
        prompt.should_receive(:ask).with("Please select a task to start working on (1-14, 'q' to exit)".bold).and_return('2')
        prompt.should_receive(:ask).with("How many points do you estimate for it? (0,1,2,3)".bold).and_return('3')

        PT::Flow::UI.new %w{ start }

        WebMock.should have_requested(:get, "#{endpoint}/projects/102622/stories?filter=current_state:unscheduled,unstarted,started")
        WebMock.should have_requested(:put, "#{endpoint}/projects/102622/stories/4459994").with(body: /<estimate>3<\/estimate>/)
        WebMock.should have_requested(:put, "#{endpoint}/projects/102622/stories/4459994").with(body: /<owned_by>Jon Mischo<\/owned_by>/)
        WebMock.should have_requested(:put, "#{endpoint}/projects/102622/stories/4459994").with(body: /<current_state>started<\/current_state>/)

        current_branch.should == 'master-4459994'
      end
    end

    context 'given an already estimated story' do
      it "does not prompt to estimate" do
        prompt.should_receive(:ask).once.with("Please select a task to start working on (1-14, 'q' to exit)".bold).and_return('3')
        PT::Flow::UI.new %w{ start }
      end
    end

    context 'when run from a feature branch' do
      before { system('git checkout -B new_feature') }

      it "creates an appropriately namespaced branch" do
        prompt.should_receive(:ask).and_return('3')
        PT::Flow::UI.new %w{ start }
        current_branch.should == 'new_feature-4460038'
      end
    end

    context 'when run from an existing story branch' do
      before { system('git checkout -B new_feature-12345') }

      it "creates a branch within the same namespace" do
        prompt.should_receive(:ask).and_return('3')
        PT::Flow::UI.new %w{ start }
        current_branch.should == 'new_feature-4460038'
      end
    end
  end

  describe '#finish' do
    before do
      system('git checkout -B new_feature-12345')
      system('git remote add origin git@github.com:balvig/pt-flow.git')
    end

    it "pushes the current branch to origin, flags the story as finished, and opens a github pull request" do
      PT::Flow::UI.any_instance.should_receive(:run).with('git push origin new_feature-12345')
      PT::Flow::UI.any_instance.should_receive(:run).with("open 'https://github.com/balvig/pt-flow/pull/new/new_feature...new_feature-12345?title=Unestimated Feature [#4459994]&body=http://www.pivotaltracker.com/story/show/4459994'")
      PT::Flow::UI.new %w{ finish }
    end
  end
end
