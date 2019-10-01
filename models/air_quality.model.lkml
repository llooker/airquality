connection: "snowlooker"

# include all the views
include: "/views/**/*.view"

datagroup: air_quality_default_datagroup {
  sql_trigger: SELECT max(completed_at) FROM ecomm.etl_jobs;;
  max_cache_age: "1 hour"
}

persist_with: air_quality_default_datagroup

explore: order_items {
#       access_filter:{
#       field: products.brand
#       user_attribute: brand
#     }
  label: "(1) Orders, Items and Users"
  view_name: order_items
  join: inventory_items {
    #Left Join only brings in items that have been sold as order_item
    type: full_outer
    relationship: one_to_one
    sql_on: ${inventory_items.id} = ${order_items.inventory_item_id} ;;
  }

  join: users {
    relationship: many_to_one
    sql_on: ${order_items.user_id} = ${users.id} ;;
  }

  join: user_order_facts {
    view_label: "Users"
    relationship: many_to_one
    sql_on: ${user_order_facts.user_id} = ${order_items.user_id} ;;
  }

  join: products {
    relationship: many_to_one
    sql_on: ${products.id} = ${inventory_items.product_id} ;;
  }


  join: distribution_centers {
    type: left_outer
    sql_on: ${distribution_centers.id} = ${inventory_items.product_distribution_center_id} ;;
    relationship: many_to_one
  }
}
