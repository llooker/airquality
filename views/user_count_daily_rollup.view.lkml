view: user_count_daily_rollup {
  sql_table_name: public.user_count_daily_rollup ;;

  dimension: column {
    type: string
    sql: ${TABLE}."?column?" ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }
}
