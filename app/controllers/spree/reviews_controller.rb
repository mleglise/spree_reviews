class Spree::ReviewsController < Spree::StoreController
  helper Spree::BaseHelper
  before_filter :load_product, :only => [:index, :new, :create, :show]
  rescue_from ActiveRecord::RecordNotFound, :with => :render_404

  def index
    @approved_reviews = Spree::Review.approved.where(product: @product)
  end

  def new
    @review = Spree::Review.new(:product => @product)
    authorize! :create, @review
  end

  # save if all ok
  def create
    params[:review][:rating].sub!(/\s*[^0-9]*\z/,'') unless params[:review][:rating].blank?

    @review = Spree::Review.new(review_params)
    @review.product = @product
    @review.user = spree_current_user if spree_user_signed_in?
    @review.ip_address = request.remote_ip
    @review.locale = I18n.locale.to_s if Spree::Reviews::Config[:track_locale]

    authorize! :create, @review
    respond_to do |format|
      if @review.save
        flash[:success] = "Review has been saved!"
        format.html { redirect_to spree.product_path(@product), notice: Spree.t(:review_successfully_submitted) }
        format.json { render json: @review, status: :created }
        format.js   { render }
      else
        flash[:error]   = "Review has not been saved!"
        format.html { render action: 'new' }
        format.js   { render inline: '', layout: true }
        format.json { render json: @review.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def update
    @review = Spree::Review.find(params[:id])
    authorize! :update, @review
    respond_to do |format|
      if @review.update(review_params)
        format.html { redirect_to [@review.product, @review], notice: Spree.t(:review_successfully_updated) }
        format.json { render json: @review, status: :updated }
      else
        format.html { render action: 'edit' }
        format.json { render json: @review.errors, status: :unprocessable_entity }
      end
    end
  end

  def show
    @review = Spree::Review.find(params[:id])

    respond_to do |format|
      if @review
        format.html { render }
        format.js   { render }
        format.json { render json: @review }
      else
        format.html { render action: 'new' }
        format.js   { render inline: '', layout: true }
        format.json { render json: @review.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def load_product
    @product = Spree::Product.friendly.find(params[:product_id])
  end

  def permitted_review_attributes
    [:rating, :title, :review, :name, :show_identifier]
  end

  def review_params
    params.require(:review).permit(permitted_review_attributes)
  end

end
