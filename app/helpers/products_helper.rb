module ProductsHelper

  def render_product_content(column, entity)
    value = column.value_object(entity)
    product_column_value column, entity, value
  end

  def product_column_value(column, entity, value)
    case column.name
    when :id
      link_to value, product_path(entity)
    else
      format_object(value)
    end
  end

  def show_attribute(label, text, options={})
    options[:class] = [options[:class] || "", 'attribute'].join(' ')
    content_tag(
      'div',
      content_tag('div', label + ":", :class => 'label') +
        content_tag('div', text, :class => 'value'),
      options)
  end

  # Returns header for view  product form
  def product_header(product)
    product.product_name
  end

end
