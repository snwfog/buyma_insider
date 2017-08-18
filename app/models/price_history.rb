# == Schema Information
#
# Table name: price_histories
#
#  id         :integer          not null, primary key
#  article_id :integer          not null
#  price      :decimal(18, 5)   not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class PriceHistory < ActiveRecord::Base
  DEFAULT_CURRENCY = :CAD
  belongs_to :article
end
