class ProductsController < ApplicationController
  model_object Product
  before_action :find_model_object, :except => [:index, :new, :create]
  before_action :find_project_from_association, :except => [:index, :new, :create]
  before_action :find_project_by_project_id, :only => [:index, :new, :create]
  before_action :make_new_product, :only => [:new, :create]
  before_action :find_optional_issue, :only => [:edit, :new]
  before_action :authorize

  rescue_from Query::StatementInvalid, :with => :query_statement_invalid

  helper :sort
  include SortHelper
  helper :queries
  include QueriesHelper

  def index
    use_session = !request.format.csv?
    retrieve_query(ProductQuery, use_session)

    if @query.valid?
      respond_to do |format|
        format.html {
          @product_count = @query.product_count
          @product_pages = Paginator.new @product_count, per_page_option, params['page']
          @products = @query.products(:offset => @product_pages.offset,
                                      :limit => @product_pages.per_page)
          render :layout => !request.xhr?
        }
        format.csv  {
          @products = @query.products
          send_data(query_to_csv(@products, @query, params[:csv]),
                    :type => 'text/csv; header=present',
                    :filename => 'products.csv')
        }
      end
    else
      respond_to do |format|
        format.html { render :layout => !request.xhr? }
        format.any(:csv) { head 422 }
      end
    end
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def show
    retrieve_previous_and_next_product_ids
  end

  def new
    respond_to do |format|
      format.html { render :action => 'new', :layout => !request.xhr? }
      format.js
    end
  end

  def create
    @product.safe_attributes = params[:product]
    if @product.save
        flash[:notice] = l(:notice_successful_create)
        redirect_back_or_default(project_products_path(@project))
    else
      render :action => 'new'
    end
  end

  def edit
    respond_to do |format|
      format.html { render :action => 'edit', :layout => !request.xhr? }
      format.js
    end
  end

  def update
    @product.safe_attributes = params[:product]
    if @product.save
      flash[:notice] = l(:notice_successful_update)
      redirect_back_or_default(project_products_path(@project))
    else
      render :action => 'edit'
    end
  end

  def destroy
    @product.destroy!
    redirect_back_or_default(project_products_path(@project))
  end

  private

  def make_new_product
    @product = @project.products.new
  end

  def find_optional_issue
    if params[:product].present? && params[:product][:issue_id].present?
      @product.issue = Issue.where(id:params[:product][:issue_id]).first
    end
  end

  def retrieve_query_from_session(klass=IssueQuery)
    session_key = klass.name.underscore.to_sym
    session_data = session[session_key]

    if session_data
      if session_data[:id]
        @query = klass.find_by_id(session_data[:id])
        return unless @query
      else
        @query = klass.new(:name => "_",
                           :filters => session_data[:filters],
                           :group_by => session_data[:group_by],
                           :column_names => session_data[:column_names],
                           :totalable_names => session_data[:totalable_names],
                           :sort_criteria => session[session_key][:sort])
      end
      if session_data.has_key?(:project_id)
        @query.project_id = session_data[:project_id]
      else
        @query.project = @project
      end
      @query
    end
  end

  def retrieve_previous_and_next_product_ids
    if params[:prev_product_id].present? || params[:next_product_id].present?
      @prev_product_id = params[:prev_product_id].presence.try(:to_i)
      @next_product_id = params[:next_product_id].presence.try(:to_i)
      @product_position = params[:product_position].presence.try(:to_i)
      @product_count = params[:product_count].presence.try(:to_i)
    else
      retrieve_query_from_session(ProductQuery)
      if @query
        @per_page = per_page_option
        limit = 500
        product_ids = @query.product_ids(:limit => (limit + 1))
        if (idx = product_ids.index(@product.id)) && idx < limit
          if product_ids.size < 500
            @product_position = idx + 1
            @product_count = product_ids.size
          end
          @prev_product_id = product_ids[idx - 1] if idx > 0
          @next_product_id = product_ids[idx + 1] if idx < (product_ids.size - 1)
        end
        query_params = @query.as_params
        if @product_position
          query_params = query_params.merge(:page => (@product_position / per_page_option) + 1,
                                            :per_page => per_page_option)
        end
        @query_path = project_products_path(@query.project, query_params)
      end
    end
  end
end
