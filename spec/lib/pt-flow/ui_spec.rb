require 'spec_helper'

module PT::Flow
  describe UI do

    let(:endpoint) { "http://www.pivotaltracker.com/services/v3" }
    let(:prompt) { double('HighLine') }

    before do
      HighLine.stub(new: prompt)
      stub_request(:get, /projects$/).to_return(body: fixture_file('projects.xml'))
      stub_request(:get, /stories\?/).to_return(body: fixture_file('stories.xml'))
      stub_request(:post, /stories$/).to_return(body: fixture_file('chore.xml'))
      stub_request(:any, /stories\/\d+/).to_return do |request|
        id = request.uri.to_s.split('/').last
        { body: fixture_file("story_#{id}.xml") }
      end
    end

    describe '#start' do
      context 'given an unestimated story' do
        it "shows lists of stories - choosing one asks you to estimate, starts/assigns the story on pt and checks out a new branch." do
          prompt.should_receive(:ask).with("Please select a task to start working on (1-14, 'q' to exit)".bold).and_return('2')
          prompt.should_receive(:ask).with("How many points do you estimate for it? (0,1,2,3)".bold).and_return('3')

          UI.new('start')

          WebMock.should have_requested(:get, "#{endpoint}/projects/102622/stories?filter=current_state:unstarted,started")
          WebMock.should have_requested(:put, "#{endpoint}/projects/102622/stories/4459994").with(body: /<estimate>3<\/estimate>/)
          WebMock.should have_requested(:put, "#{endpoint}/projects/102622/stories/4459994").with(body: /<owned_by>Jon Mischo<\/owned_by>/)
          WebMock.should have_requested(:put, "#{endpoint}/projects/102622/stories/4459994").with(body: /<current_state>started<\/current_state>/)

          current_branch.should == 'master.as-a-user-i-should-see-an-unestimated-feature-with-.4459994'
        end
      end

      context 'given an already estimated story' do
        it "does not prompt to estimate" do
          prompt.should_receive(:ask).once.with("Please select a task to start working on (1-14, 'q' to exit)".bold).and_return('3')
          UI.new('start')
        end
      end

      context 'when run from a feature branch' do
        before { system('git checkout -B new_feature') }

        it "creates an appropriately namespaced branch" do
          prompt.should_receive(:ask).and_return('3')
          UI.new('start')
          current_branch.should == 'new_feature.this-is-for-comments.4460038'
        end
      end

      context 'when run from an existing story branch' do
        before { system('git checkout -B new_feature.as-a-user-i-should.4459994') }

        it "creates a branch within the same namespace" do
          prompt.should_receive(:ask).and_return('3')
          UI.new('start')
          current_branch.should == 'new_feature.this-is-for-comments.4460038'
        end
      end

      context 'given a string' do
        it "creates and starts a new story with that name" do
          prompt.should_receive(:ask).with("Type? (c)hore, (b)ug, (f)eature".bold).and_return('c')

          UI.new('start', ['a new feature'])

          WebMock.should have_requested(:post, "#{endpoint}/projects/102622/stories").with(body: /<name>a new feature<\/name>/).with(body: /<story_type>chore<\/story_type>/).with(body: /<requested_by>Jon Mischo<\/requested_by>/)
          WebMock.should have_requested(:put, "#{endpoint}/projects/102622/stories/4459994").with(body: /<owned_by>Jon Mischo<\/owned_by>/)
          WebMock.should have_requested(:put, "#{endpoint}/projects/102622/stories/4459994").with(body: /<current_state>started<\/current_state>/)
        end
      end

      context 'given various filters' do
        before do
          prompt.should_receive(:ask).with("Please select a task to start working on (1-14, 'q' to exit)".bold).and_return('2')
          prompt.should_receive(:ask).with("How many points do you estimate for it? (0,1,2,3)".bold).and_return('3')
        end

        it "it allows showing icebox contents" do
          UI.new('start', ['--filter=icebox'])
          WebMock.should have_requested(:get, "#{endpoint}/projects/102622/stories?filter=current_state:unscheduled")
        end

        it "it allows showing your own tasks" do
          UI.new('start', ['--filter=me'])
          WebMock.should have_requested(:get, "#{endpoint}/projects/102622/stories?filter=current_state:unscheduled,unstarted,started+owner:Jon+Mischo")
        end
      end
    end

    describe '#finish' do
      context 'ssh repo' do
        before do
          ENV['BROWSER'] = ''
          system('git checkout -B new_feature')
          system('git remote rm origin')
          system('git remote add origin git@github.com:cookpad/pt-flow.git')

          prompt.should_receive(:ask).and_return('3')
          UI.new('start')
        end

        context 'no options' do
          it "pushes the current branch to origin, flags the story as finished, and opens github pull request URL" do
            UI.any_instance.should_receive(:run).with('git push origin new_feature.this-is-for-comments.4460038 -u')
            UI.any_instance.should_receive(:run).with("open \"https://github.com/cookpad/pt-flow/compare/new_feature...new_feature.this-is-for-comments.4460038?expand=1&title=This%20is%20for%20comments%20[Delivers%20%234460038]\"")
            UI.new('finish')
            current_branch.should == 'new_feature.this-is-for-comments.4460038'
            WebMock.should have_requested(:put, "#{endpoint}/projects/102622/stories/4460038").with(body: /<current_state>finished<\/current_state>/)
          end
        end

        context 'give option --wip' do
          it "pushes the current branch to origin, and opens github [WIP] pull request URL" do
            UI.any_instance.should_receive(:run).with('git push origin new_feature.this-is-for-comments.4460038 -u')
            UI.any_instance.should_receive(:run).with("open \"https://github.com/cookpad/pt-flow/compare/new_feature...new_feature.this-is-for-comments.4460038?expand=1&title=[WIP]%20This%20is%20for%20comments%20[Delivers%20%234460038]\"")
            UI.new('finish', ['--wip'])
          end
        end

        context 'given option --deliver' do
          it "pushes the current branch to origin, flags the story as finished, opens github pull request, merges it in and returns to master and pulls" do
            UI.any_instance.should_receive(:run).with('git push origin new_feature.this-is-for-comments.4460038 -u')
            UI.any_instance.should_receive(:run).with("hub pull-request -b new_feature -h cookpad:new_feature.this-is-for-comments.4460038 -m \"This is for comments [Delivers #4460038]\"")
            UI.any_instance.should_receive(:run).with('git checkout new_feature')
            UI.any_instance.should_receive(:run).with('git pull')
            UI.any_instance.should_receive(:run).with("git merge new_feature.this-is-for-comments.4460038 --no-ff -m \"This is for comments [Delivers #4460038]\"")
            UI.any_instance.should_receive(:run).with('git push origin new_feature')
            UI.new('finish', ['--deliver'])
          end
        end
      end
    end

    context 'https repo' do
      before do
        system('git checkout -B new_feature')
        system('git remote rm origin')
        system('git remote add origin https://github.com/balvig/pt-flow.git')

        prompt.should_receive(:ask).and_return('3')
        UI.new('start')
      end

      it "pushes the current branch to origin, flags the story as finished, and opens a github pull request" do
        UI.any_instance.should_receive(:run).with('git push origin new_feature.this-is-for-comments.4460038 -u')
        UI.any_instance.should_receive(:run).with("open \"https://github.com/balvig/pt-flow/compare/new_feature...new_feature.this-is-for-comments.4460038?expand=1&title=This%20is%20for%20comments%20[Delivers%20%234460038]\"")
        UI.new('finish')
      end
    end

    context 'finishing a bug' do
      before do
        system('git remote rm origin')
        system('git remote add origin git@github.com:cookpad/pt-flow.git')
        system('git checkout -B master.this-is-a-bug.4492080')
      end

      it "prepends title with Bugfix: " do
        UI.any_instance.should_receive(:run).with('git push origin master.this-is-a-bug.4492080 -u')
        UI.any_instance.should_receive(:run).with("open \"https://github.com/cookpad/pt-flow/compare/master...master.this-is-a-bug.4492080?expand=1&title=Bugfix:%20This%20is%20a%20bug%20[Delivers%20%234492080]\"")
        UI.new('finish')
      end
    end
  end
end
