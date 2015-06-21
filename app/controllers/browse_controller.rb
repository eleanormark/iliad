class BrowseController <  ApplicationController
  before_filter :authenticate

  def index
    @model = Project
    @record = @model[@model.identity => "UCSF Immunoprofiler"]
  end

  def model
    # Get the model name
    @model_name = params[:model]
    @record_name = params[:name]
  end

  def json
    # Get the model name
    @model = Magma.instance.get_model params[:model]
    @record = @model[@model.identity => params[:name]]

    render json: basic_payload
  end

  def update
    # Update a model, redirect to the model view
    @model = Magma.instance.get_model params[:model]
    @record = @model[params[:record_id]]

    validate_update(params)

    if @errors.count > 0
      render json: { errors: @errors }, status: 422
      return
    end

    create_or_update_links (params[:link] || {}).select do |att,val|
      @model.attributes[att] && !@model.attributes[att].read_only?
    end

    # mark any file uploads as changed.
    @model.attributes.select do |name,att|
      att.is_a?(Magma::DocumentAttribute) || att.is_a?(Magma::ImageAttribute)
    end.each do |name, att|
      if params[:values][name]
        @record.modified! name
      end
    end

    begin
      @record.update (params[:values] || {}).select do |att,val|
        @model.attributes[att] && !@model.attributes[att].read_only?
      end
    rescue Magma::LoadFailed => m
      logger.info m.complaints
    end

    render json: basic_payload
  end

  def new
    @params = params
    @model = Magma.instance.get_model params[:model]
  end

  def create
    @model = Magma.instance.get_model params[:model]

    hash = params[:values]
    # add any keys to the hash
    if params[:key]
      params[:key].each do |parent, identifier|
        foreign = Magma.instance.get_model parent
        frecord = foreign[foreign.identity => identifier]
        hash.update :"#{foreign.name.snake_case}_id" => frecord.id
      end
    end
    logger.info hash

    @record = @model.create hash

    redirect_to browse_model_path(@model.name.snake_case, @record.identifier)
  end

  private
  def basic_payload
    { record: @record.json_template, model: json_update(@model) }
  end

  def json_update model
    if update_class(model)
      updater = update_class(model).new(model)
      updater.json_template
    else
      model.json_template
    end
  end

  def update_class model
    return nil unless [Sample].include? model
    name = "#{model.name.snake_case}_json_update".camel_case.to_sym
    Kernel.const_get name
  end

  def validate_update params
    @errors = []
    validate_links params[:link] if params[:link]
    validate_values params[:values] if params[:values]
  end

  def validate_links links
    # pull up the appropriate model
    links.each do |fname, link|
      next unless link && link.size > 0
      foreign_model = Magma.instance.get_model fname
      att = foreign_model.attributes[foreign_model.identity]
      att.validate link do |error|
        @errors.push error
      end
    end
  end

  def validate_values values
    values.each do |name, value|
      @model.attributes[name.to_sym].validate value do |error|
        @errors.push error
      end
    end
  end

  def create_or_update_links links
    links.each do |fname,link|
      next if link.blank?
      logger.info "Attempting to make #{link} for #{fname} which is a #{ @model.attributes[fname.to_sym].class }"
      case @model.attributes[fname.to_sym]
      when Magma::ForeignKeyAttribute
        # See if you can find the appropriate model
        foreign_model = Magma.instance.get_model fname
        logger.info "Found #{foreign_model}"
        # now see if the link exists
        if foreign_model
          obj = foreign_model.find_or_create(foreign_model.identity => link)
          @record[ :"#{fname}_id" ] = obj.id if obj
        end
      when Magma::ChildAttribute
        child_model = Magma.instance.get_model fname
        if child_model
          child_model.find_or_create(child_model.identity => link) do |obj|
            obj[ :"#{@model.name.snake_case}_id" ] = @record.id
          end
        end
      when Magma::CollectionAttribute
        child_model = Magma.instance.get_model fname
        link.each do |ilink|
          next if ilink.blank?
          if child_model
            logger.info "Trying to create #{child_model} for #{ilink} with #{child_model.identity}"
            child_model.find_or_create(child_model.identity => ilink) do |obj|
              logger.info "Setting #{@model.name.snake_case}_id on #{obj}"
              obj[ :"#{@model.name.snake_case}_id" ] = @record.id
            end
          end
        end
      end
    end
  end
end