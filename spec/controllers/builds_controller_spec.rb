require "spec_helper"

describe BuildsController do
  let(:project) { Factory(:project, :name => 'name') }
  let(:build) { Factory.create(:build, :project => project, :number => 10) }

  it "loads one build" do
    get :show, :project_name => project.name, :build_number => build.number

    response.should be_ok
    assigns[:project].should == project
    assigns[:build].should == build
  end

  it "denotes an unknown project" do
    get :show, :project_name => 'random project', :build_number => 1
    response.should be_not_found
  end

  it "denotes an unknown build" do
    get :show, :project_name => project.name, :build_number => 1
    response.should be_not_found
  end

  describe 'artefacts' do
    before(:each) do
      Paths.stub!(:projects).and_return('root')
    end

    it 'sends a requested file that lives beneath the given directory' do
      full_path = 'root/name/builds/10/artefacts/index.html'
      Environment.stub!(:expand_path).with(full_path).and_return(full_path)
      Environment.stub!(:exist?).with(full_path).and_return(true)
      controller.stub!(:render)
      controller.should_receive(:send_file).with(full_path, {:disposition => 'inline', :content_type => 'text/html'})
      get :artefact, :project_name => project.name, :build_number => build.number, :path => 'index.html'
    end

    it 'raises an error if a file outside the given directory was requested' do
      full_path = 'root/name/builds/10/artefacts/index.html'
      Environment.stub!(:expand_path).with('root/name/builds/10/artefacts/../../index.html').and_return('root/name/builds/index.html')
      get :artefact, :project_name => project.name, :build_number => build.number, :path => '../../index.html'
      response.status.should == 403
    end

    it 'renders the directory view if a directory was requested' do
      full_path = 'root/name/builds/10/artefacts/assets'
      Environment.stub!(:expand_path).with(full_path).and_return(full_path)
      Environment.stub!(:directory?).with(full_path).and_return(true)
      Dir.stub!(:entries).with(full_path).and_return(['.', '..', 'entry1', 'entry2'])
      get :artefact, :project_name => project.name, :build_number => build.number, :path => 'assets'
      response.should be_ok
      assigns[:entries].should == ['assets/entry1', 'assets/entry2']
    end

    it 'returns a 404 if the path is not found' do
      full_path = 'root/name/builds/10/artefacts/non_existent_file.html'
      Environment.stub!(:expand_path).with(full_path).and_return(full_path)
      Environment.stub!(:exist?).with(full_path).and_return(false)
      get :artefact, :project_name => project.name, :build_number => build.number, :path => 'non_existent_file.html'
      response.should be_not_found
    end
  end

  it "cancels the build" do
    build = Factory(:build, :project => Factory(:project))
    @request.env['HTTP_REFERER'] = 'http://referer/'
    put :cancel, :project_name => build.project.name, :build_number => build.number
    build.reload.should be_cancelled
    response.should redirect_to(:back)
  end
end

