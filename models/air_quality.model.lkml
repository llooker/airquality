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
  label: "(1) Air Quality Monitoring"
  view_name: air_quality_facts
  join: AQI_Measurement_Devices {
    relationship: many_to_one
    sql_on: ${air_quality_facts.user_id} = ${AQI_Measurement_Devices.id} ;;
  }

}
