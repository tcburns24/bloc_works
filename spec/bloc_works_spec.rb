require "spec_helper"

describe BlocWorks do
  it "has a version number" do
    expect(BlocWorks::VERSION).not_to be nil
  end

  it "does something useful" do
    expect(false).to eq(true)
  end
end


# ---------------------------------------------------
RSpec.describe BookController, type: :controller do
  let(:my_book) { create(:book) }

  describe "GET show" do
    it "returns http success" do
      get :show, book_id: my_book.id, id: my_book.id
      expect(response).to have_http_status(:success)
    end

    it "renders the #show view" do
      get :show, book_id: my_book.id, id: my_book.id
      expect(response).to render_template :show
    end

    it "assigns my_post to @post" do
      get :show, book_id: my_book.id, id: my_book.id
      expect(assigns(:book)).to eq(my_book)
    end

    describe "GET new" do
      it "returns http redirect" do
        get :new, book_id: my_book.id
        expect(response).to redirect_to(new_session_path)
      end
    end

    describe "POST create" do
      it "returns http redirect" do
        post :create, book_id: my_book.id, book: {title: RandomData.random_sentence, body: RandomData.random_paragraph}
        expect(response).to redirect_to(new_session_path)
      end
    end

    describe "PUT update" do
      it "returns http redirect" do
        new_title = RandomData.random_sentence
        new_body = RandomData.random_paragraph

        put :update, book_id: my_book.id, id: my_book.id, book: {title: new_title, body: new_body}
        expect(response).to redirect_to(new_session_path)
      end
    end

    describe "DELETE destroy" do
      it "returns http redirect" do
        delete :destroy, book_id: my_book.id, id: my_book.id
        expect(response).to redirect_to(new_session_path)
      end
    end
  end

end
