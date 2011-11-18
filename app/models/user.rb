class User
  include Mongoid::Document
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
         
         field :full_name
         field :admin, type: Boolean, default: false

       
         validates_presence_of :full_name
                  
         def update_with_password(params={})
           params.delete(:current_password)
           self.update_without_password(params)
         end
        
end
