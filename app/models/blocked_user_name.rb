# prevent user names being taken that could belong to route paths
# or reserved or offensive
class BlockedUserName < ApplicationRecord
  validates_uniqueness_of :user_name

end
