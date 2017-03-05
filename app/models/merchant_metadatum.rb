require 'nobrainer'

class MerchantMetadatum
  include NoBrainer::Document
 
  belongs_to :merchant, required: true

  field :id,           primary_key: true, required: true
  field :name,         type: String, required: true
  field :base_url,     type: String, required: true
  field :pager_css,    type: String
  field :item_css,     type: String, required: true
  field :index_pages,  type: Set, required: true
  field :ssl,          type: Boolean

  alias_method :code,   :id
  alias_method :code=,  :id=

  def latests
    # This is a flat criteria, might look wrong
    # but its working
    # articles.shinchyaku
  end

  def sales
    # articles.sales
  end
end