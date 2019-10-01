connection: "snowlooker"

# include all the views
include: "/views/**/*.view"

datagroup: air_quality_default_datagroup {
  # sql_trigger: SELECT MAX(id) FROM etl_log;;
  max_cache_age: "1 hour"
}

persist_with: air_quality_default_datagroup
