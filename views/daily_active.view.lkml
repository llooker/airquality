view: daily_active {
  sql_table_name: public.daily_active ;;

  dimension_group: activity {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}.activity_date ;;
  }

  dimension: daily_active {
    type: number
    sql: ${TABLE}.daily_active ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }
}
