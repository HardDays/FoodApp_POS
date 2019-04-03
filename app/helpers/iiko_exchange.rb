class IIKOExchange
  include HTTParty

  def initialize(restaurant)
    self.class.base_uri restaurant.iiko_url

    response = self.class.get(
      "/resto/api/auth?login=#{restaurant.iiko_login}&pass=#{restaurant.iiko_password}",
      headers: {
        'Content-Type' => 'application/json'
      }
    )

    if response.code == 200
      @token = response
    end
  end

  def menu_items
    menu_items = self.class.get(
      "/resto/api/v2/entities/products/list?includeDeleted=false&types=DISH",
      headers: {
        'Content-Type' => 'application/json',
        'Cookie' => "key=#{@token}"
      }
    ).body

    if menu_items == ""
      menu_items = "{}"
    end

    menu_items
  end

  def menu_categories
    menu_categories = self.class.get(
      "/resto/api/v2/entities/products/category/list?includeDeleted=false",
      headers: {
        'Content-Type' => 'application/json',
        'Cookie' => "key=#{@token}"
      }
    ).body

    if menu_categories == ""
      menu_categories = "{}"
    end

    menu_categories
  end

  def get_menu_category
    menu_categories = self.class.get(
      "/resto/api/v2/entities/products/category/list?includeDeleted=false",
      headers: {
        'Content-Type' => 'application/json',
        'Cookie' => "key=#{@token}"
      }
    ).body

    if menu_categories == ""
      menu_categories = "{}"
    end

    menu_categories
  end
end
