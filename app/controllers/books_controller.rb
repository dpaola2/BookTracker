class BooksController < ApplicationController
  before_action :set_bootstrap
  before_action :authenticate_user!
  before_action :set_book, only: %i[ show edit update destroy ]

  # GET /books or /books.json
  def index
    if params[:q].present?
      @q = current_user.books.ransack(params[:q])
      @pagy, @books = pagy(@q.result(distinct: true))
    else
      @q = current_user.books.ransack(params[:q])
      @pagy, @books = pagy(current_user.books.order(created_at: :desc))
    end
  end

  # GET /books/1 or /books/1.json
  def show
  end

  # GET /books/new
  def new
    @book = Book.new
  end

  # GET /books/1/edit
  def edit
  end

  # POST /books or /books.json
  def create
    @book = current_user.books.new(book_params)

    respond_to do |format|
      if @book.save
        searcher = IsbnSearcher.new(book: @book).search

        format.html { redirect_to book_url(@book), notice: "Book was successfully created." }
        format.json { render :show, status: :created, location: @book }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @book.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /books/1 or /books/1.json
  def update
    respond_to do |format|
      if @book.update(book_params)
        searcher = IsbnSearcher.new(book: @book).search

        format.html { redirect_to book_url(@book), notice: "Book was successfully updated." }
        format.json { render :show, status: :ok, location: @book }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @book.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /books/1 or /books/1.json
  def destroy
    @book.destroy

    respond_to do |format|
      format.html { redirect_to books_url, notice: "Book was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_book
      @book = current_user.books.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def book_params
      params.require(:book).permit(:title, :author, :isbn, :shelf_id, :image, :comments)
    end
end
