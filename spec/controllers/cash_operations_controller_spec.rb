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

describe CashOperationsController do

  # This should return the minimal set of attributes required to create a valid
  # CashOperation. As you add validations to CashOperation, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) { { "cash_shift" => "" } }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # CashOperationsController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  describe "GET index" do
    it "assigns all cash_operations as @cash_operations" do
      cash_operation = CashOperation.create! valid_attributes
      get :index, {}, valid_session
      assigns(:cash_operations).should eq([cash_operation])
    end
  end

  describe "GET show" do
    it "assigns the requested cash_operation as @cash_operation" do
      cash_operation = CashOperation.create! valid_attributes
      get :show, {:id => cash_operation.to_param}, valid_session
      assigns(:cash_operation).should eq(cash_operation)
    end
  end

  describe "GET new" do
    it "assigns a new cash_operation as @cash_operation" do
      get :new, {}, valid_session
      assigns(:cash_operation).should be_a_new(CashOperation)
    end
  end

  describe "GET edit" do
    it "assigns the requested cash_operation as @cash_operation" do
      cash_operation = CashOperation.create! valid_attributes
      get :edit, {:id => cash_operation.to_param}, valid_session
      assigns(:cash_operation).should eq(cash_operation)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new CashOperation" do
        expect {
          post :create, {:cash_operation => valid_attributes}, valid_session
        }.to change(CashOperation, :count).by(1)
      end

      it "assigns a newly created cash_operation as @cash_operation" do
        post :create, {:cash_operation => valid_attributes}, valid_session
        assigns(:cash_operation).should be_a(CashOperation)
        assigns(:cash_operation).should be_persisted
      end

      it "redirects to the created cash_operation" do
        post :create, {:cash_operation => valid_attributes}, valid_session
        response.should redirect_to(CashOperation.last)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved cash_operation as @cash_operation" do
        # Trigger the behavior that occurs when invalid params are submitted
        CashOperation.any_instance.stub(:save).and_return(false)
        post :create, {:cash_operation => { "cash_shift" => "invalid value" }}, valid_session
        assigns(:cash_operation).should be_a_new(CashOperation)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        CashOperation.any_instance.stub(:save).and_return(false)
        post :create, {:cash_operation => { "cash_shift" => "invalid value" }}, valid_session
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested cash_operation" do
        cash_operation = CashOperation.create! valid_attributes
        # Assuming there are no other cash_operations in the database, this
        # specifies that the CashOperation created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        CashOperation.any_instance.should_receive(:update_attributes).with({ "cash_shift" => "" })
        put :update, {:id => cash_operation.to_param, :cash_operation => { "cash_shift" => "" }}, valid_session
      end

      it "assigns the requested cash_operation as @cash_operation" do
        cash_operation = CashOperation.create! valid_attributes
        put :update, {:id => cash_operation.to_param, :cash_operation => valid_attributes}, valid_session
        assigns(:cash_operation).should eq(cash_operation)
      end

      it "redirects to the cash_operation" do
        cash_operation = CashOperation.create! valid_attributes
        put :update, {:id => cash_operation.to_param, :cash_operation => valid_attributes}, valid_session
        response.should redirect_to(cash_operation)
      end
    end

    describe "with invalid params" do
      it "assigns the cash_operation as @cash_operation" do
        cash_operation = CashOperation.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        CashOperation.any_instance.stub(:save).and_return(false)
        put :update, {:id => cash_operation.to_param, :cash_operation => { "cash_shift" => "invalid value" }}, valid_session
        assigns(:cash_operation).should eq(cash_operation)
      end

      it "re-renders the 'edit' template" do
        cash_operation = CashOperation.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        CashOperation.any_instance.stub(:save).and_return(false)
        put :update, {:id => cash_operation.to_param, :cash_operation => { "cash_shift" => "invalid value" }}, valid_session
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested cash_operation" do
      cash_operation = CashOperation.create! valid_attributes
      expect {
        delete :destroy, {:id => cash_operation.to_param}, valid_session
      }.to change(CashOperation, :count).by(-1)
    end

    it "redirects to the cash_operations list" do
      cash_operation = CashOperation.create! valid_attributes
      delete :destroy, {:id => cash_operation.to_param}, valid_session
      response.should redirect_to(cash_operations_url)
    end
  end

end
