require 'spec_helper'

module PT::Flow
  describe UI do

    let(:project) { double('Project', id: 1, use_https: false) }
    let(:task) { double('Task', id: 1, name: 'Do this', current_state: 'Unscheduled', estimate: 1, errors: []) }
    let(:prompt) { double('HighLine') }

    before do
      PivotalTracker::Project.stub(all: [], find: project)
      PivotalTracker::Story.stub(find: task)
      HighLine.stub(new: prompt)
    end

    describe '#start' do
      before do
        project.stub(stories: double('stories', all: [task]))
      end

      context 'given no args' do
        it "shows lists of tasks - choosing one starts/assigns the task on pt and checks out a new branch." do
          prompt.should_receive(:ask).with("Please select a task to start working on (1-1, 'q' to exit)".bold).and_return('1')
          task.should_receive(:update).with(owned_by: 'Jens Balvig').and_return(task)
          task.should_receive(:update).with(current_state: 'started').and_return(task)
          UI.any_instance.should_receive(:`).with('git checkout -B 1')

          ui = UI.new %w{ start }
        end
      end
      context 'given a number' do
        it "starts/assigns the task on pt and checks out a new branch." do
          task.should_receive(:update).with(owned_by: 'Jens Balvig').and_return(task)
          task.should_receive(:update).with(current_state: 'started').and_return(task)
          UI.any_instance.should_receive(:`).with('git checkout -B 1')

          ui = UI.new %w{ start 1 }
        end
      end
    end

  end
end
