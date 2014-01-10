require 'spec_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.

describe SupplyRequestsController do

  # This should return the minimal set of attributes required to create a valid
  # SupplyRequest. As you add validations to SupplyRequest, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) { { "user" => "" } }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # SupplyRequestsController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  describe "GET index" do
    it "assigns all supply_requests as @supply_requests" do
      supply_request = SupplyRequest.create! valid_attributes
      get :index, {}, valid_session
      assigns(:supply_requests).should eq([supply_request])
    end
  end

  describe "GET show" do
    it "assigns the requested supply_request as @supply_request" do
      supply_request = SupplyRequest.create! valid_attributes
      get :show, {:id => supply_request.to_param}, valid_session
      assigns(:supply_request).should eq(supply_request)
    end
  end

  describe "GET new" do
    it "assigns a new supply_request as @supply_request" do
      get :new, {}, valid_session
      assigns(:supply_request).should be_a_new(SupplyRequest)
    end
  end

  describe "GET edit" do
    it "assigns the requested supply_request as @supply_request" do
      supply_request = SupplyRequest.create! valid_attributes
      get :edit, {:id => supply_request.to_param}, valid_session
      assigns(:supply_request).should eq(supply_request)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new SupplyRequest" do
        expect {
          post :create, {:supply_request => valid_attributes}, valid_session
        }.to change(SupplyRequest, :count).by(1)
      end

      it "assigns a newly created supply_request as @supply_request" do
        post :create, {:supply_request => valid_attributes}, valid_session
        assigns(:supply_request).should be_a(SupplyRequest)
        assigns(:supply_request).should be_persisted
      end

      it "redirects to the created supply_request" do
        post :create, {:supply_request => valid_attributes}, valid_session
        response.should redirect_to(SupplyRequest.last)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved supply_request as @supply_request" do
        # Trigger the behavior that occurs when invalid params are submitted
        SupplyRequest.any_instance.stub(:save).and_return(false)
        post :create, {:supply_request => { "user" => "invalid value" }}, valid_session
        assigns(:supply_request).should be_a_new(SupplyRequest)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        SupplyRequest.any_instance.stub(:save).and_return(false)
        post :create, {:supply_request => { "user" => "invalid value" }}, valid_session
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested supply_request" do
        supply_request = SupplyRequest.create! valid_attributes
        # Assuming there are no other supply_requests in the database, this
        # specifies that the SupplyRequest created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        SupplyRequest.any_instance.should_receive(:update_attributes).with({ "user" => "" })
        put :update, {:id => supply_request.to_param, :supply_request => { "user" => "" }}, valid_session
      end

      it "assigns the requested supply_request as @supply_request" do
        supply_request = SupplyRequest.create! valid_attributes
        put :update, {:id => supply_request.to_param, :supply_request => valid_attributes}, valid_session
        assigns(:supply_request).should eq(supply_request)
      end

      it "redirects to the supply_request" do
        supply_request = SupplyRequest.create! valid_attributes
        put :update, {:id => supply_request.to_param, :supply_request => valid_attributes}, valid_session
        response.should redirect_to(supply_request)
      end
    end

    describe "with invalid params" do
      it "assigns the supply_request as @supply_request" do
        supply_request = SupplyRequest.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        SupplyRequest.any_instance.stub(:save).and_return(false)
        put :update, {:id => supply_request.to_param, :supply_request => { "user" => "invalid value" }}, valid_session
        assigns(:supply_request).should eq(supply_request)
      end

      it "re-renders the 'edit' template" do
        supply_request = SupplyRequest.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        SupplyRequest.any_instance.stub(:save).and_return(false)
        put :update, {:id => supply_request.to_param, :supply_request => { "user" => "invalid value" }}, valid_session
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested supply_request" do
      supply_request = SupplyRequest.create! valid_attributes
      expect {
        delete :destroy, {:id => supply_request.to_param}, valid_session
      }.to change(SupplyRequest, :count).by(-1)
    end

    it "redirects to the supply_requests list" do
      supply_request = SupplyRequest.create! valid_attributes
      delete :destroy, {:id => supply_request.to_param}, valid_session
      response.should redirect_to(supply_requests_url)
    end
  end

end
