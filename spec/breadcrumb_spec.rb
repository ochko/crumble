require File.dirname(__FILE__) + '/spec_helper'

describe Crumble do
  describe "when configuring the instance" do
    it "should add trails" do
      Crumble.configure do
        crumb :profile, "Public Profile", :user_url, :user
        crumb :your_account, "Public Profile", :user_url, :user
        
        trail :accounts, :edit, [:profile, :your_account]
      end
      
      trail = Crumble.instance.trails.last
      trail.controller.should == :accounts
      trail.action.should == :edit
      trail.trail.should == [:profile, :your_account]
    end
    
    it "should add crumbs" do
      Crumble.configure do
        crumb :profile, "Public Profile", :user_url, :user
      end
      
      profile = Crumble.instance.crumbs[:profile]
      profile.title.should == "Public Profile"
      profile.url.should == :user_url
      profile.params.should == [:user]
    end
    
    it "should store the delimiter" do
      Crumble.configure do
        delimit_with "/"
      end
      
      Crumble.instance.delimiter.should == "/"
    end
    
    it "should set the flag not to link the last crumb" do
      Crumble.configure do
        dont_link_last_crumb
      end
      
      Crumble.instance.last_crumb_linked?.should == false
    end

    it "should unset the flag not to link the last crumb" do
      Crumble.configure do
        link_last_crumb
      end
      
      Crumble.instance.last_crumb_linked?.should == true
    end
    
    it "should support contexts" do
      Crumble.configure do
        context "user profile" do
          crumb :profile, "Public Profile", :user_url, :user
        end
      end
      
      profile = Crumble.instance.crumbs[:profile]
      profile.title.should == "Public Profile"
      profile.url.should == :user_url
      profile.params.should == [:user]
    end
    
    it "should not accept non-existing trails in crumb definitions" do
      lambda {
        Crumble.configure do
          trail :accounts, :edit, [:profile]
        end
      }.should raise_error(RuntimeError, "Trail for accounts/edit references non-existing crumb 'profile' (configuration file line: 70)")
    end
    
    it "should include errors for multiple missing crumb definitions" do
      lambda {
        Crumble.configure do
          trail :accounts, :edit, [:profile]
          trail :accounts, :show, [:profile]
        end
      }.should raise_error(RuntimeError, "Trail for accounts/edit references non-existing crumb 'profile' (configuration file line: 78)\nTrail for accounts/show references non-existing crumb 'profile' (configuration file line: 79)")
    end

    it "should wrap with html" do
      Crumble.configure do
        add_wrapper_html '<p id="breadcrumbs">%{crumbs}</p>'
      end

      Crumble.instance.wrapper_html.should eql '<p id="breadcrumbs">%{crumbs}</p>'
    end

    it "should store first and last css classes" do
      Crumble.configure do
        add_first_css_class_name 'home'
        add_last_css_class_name 'last'
      end

      Crumble.instance.first_css_class_name.should eql 'home'
      Crumble.instance.last_css_class_name.should eql 'last'
    end
  end
end
