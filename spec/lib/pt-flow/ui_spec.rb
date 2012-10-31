require 'spec_helper'

describe PT::Flow::UI do

  let(:endpoint) { "http://www.pivotaltracker.com/services/v3" }
  let(:prompt) { double('HighLine') }

  before do
    HighLine.stub(new: prompt)
    stub_request(:get, /projects$/).to_return(body: fixture_file('projects.xml'))
    stub_request(:get, /stories\?/).to_return(body: fixture_file('stories.xml'))
    stub_request(:post, /stories$/).to_return(body: fixture_file('chore.xml'))
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

        current_branch.should == 'master.as-a-user-i-should-see-an-unestimated-feature-with-.4459994'
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
        current_branch.should == 'new_feature.this-is-for-comments.4460038'
      end
    end

    context 'when run from an existing story branch' do
      before { system('git checkout -B new_feature.as-a-user-i-should.4459994') }

      it "creates a branch within the same namespace" do
        prompt.should_receive(:ask).and_return('3')
        PT::Flow::UI.new %w{ start }
        current_branch.should == 'new_feature.this-is-for-comments.4460038'
      end
    end

    context 'given a string' do
      it "creates and starts a new story with that name" do
        prompt.should_receive(:ask).with("Type? (c)hore, (b)ug, (f)eature".bold).and_return('c')

        PT::Flow::UI.new ['start','a new feature']

        WebMock.should have_requested(:post, "#{endpoint}/projects/102622/stories").with(body: /<name>a new feature<\/name>/).with(body: /<story_type>chore<\/story_type>/).with(body: /<requested_by>Jon Mischo<\/requested_by>/)
        WebMock.should have_requested(:put, "#{endpoint}/projects/102622/stories/4459994").with(body: /<owned_by>Jon Mischo<\/owned_by>/)
        WebMock.should have_requested(:put, "#{endpoint}/projects/102622/stories/4459994").with(body: /<current_state>started<\/current_state>/)
      end
    end
  end

  describe '#finish' do
    before do
      #TODO: Stubbed endpoint ALWAYS returns story 4459994, need a way to check it is actually getting the right id from the branch
      system('git checkout -B new_feature.as-a-user-i-should.4459994')
      system('git remote add origin git@github.com:cookpad/pt-flow.git')
    end

    it "pushes the current branch to origin, flags the story as finished, and opens a github pull request" do
      PT::Flow::UI.any_instance.should_receive(:run).with('git push origin new_feature.as-a-user-i-should.4459994')
      PT::Flow::UI.any_instance.should_receive(:run).with("hub pull-request -b new_feature -h cookpad:new_feature.as-a-user-i-should.4459994 \"As a user I should see an Unestimated Feature with a fairly long name [Delivers #4459994]\"")
      PT::Flow::UI.any_instance.should_receive(:run).with('git checkout new_feature')
      PT::Flow::UI.new %w{ finish }
      WebMock.should have_requested(:put, "#{endpoint}/projects/102622/stories/4459994").with(body: /<current_state>finished<\/current_state>/)
    end
  end
end
