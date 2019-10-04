view: air_quality_facts {
  sql_table_name: PUBLIC.ORDER_ITEMS ;;

dimension: device_id {
  primary_key: yes
  type: number
  sql: ${TABLE}.id ;;
  drill_fields: [detail*]
}

dimension: user_id {
  type: number
  hidden: yes
  sql: ${TABLE}.user_id ;;
}

measure: count {
  type: count_distinct
  sql: ${device_id} ;;
  drill_fields: [detail*]
}

dimension_group: created {
  type: time
  timeframes: [time, hour, date, week, month, year, hour_of_day, day_of_week, month_num, month_name, raw, week_of_year]
  sql: ${TABLE}.created_at ;;
  drill_fields: [detail*]
}


dimension: Daily_Air_Quality_Index {
  label: "Daily Air Quality Index"
  type: number
  value_format_name: decimal_2
  sql: ${TABLE}.sale_price ;;
  drill_fields: [detail*]
}

  dimension: air_quality_level {
    order_by_field: air_quality_sort
    sql: CASE WHEN ${Daily_Air_Quality_Index} > 300 then 'Hazardous'
          WHEN ${Daily_Air_Quality_Index} > 200 then 'Very Unhealthy'
          WHEN ${Daily_Air_Quality_Index} > 150 then 'Unhealthy'
          WHEN ${Daily_Air_Quality_Index} > 100 then 'Unhealthy for Sensitive Groups'
          WHEN ${Daily_Air_Quality_Index} > 50 then 'Moderate'
          ELSE 'Good' END;;
    drill_fields: [detail*]
    link: {
      label: "{{value}} Detail Dashboard"
      url: "/dashboards/668?AQI%20Level={{ value | encode_uri }}"
      icon_url: "http://www.looker.com/favicon.ico"
    }

    html: {% if air_quality_facts.air_quality_level._value == 'Hazardous' %}
    <p style="background:linear-gradient(to right, #FFFFFF, #800000)">{{ value }}</p>
    {% elsif air_quality_facts.air_quality_level._value == 'Very Unhealthy' %}
    <p style="background:linear-gradient(to right, #FFFFFF,#DA70D6)">{{ value }}</p>
    {% elsif air_quality_facts.air_quality_level._value == 'Unhealthy' %}
    <p style="background:linear-gradient(to right, #FFFFFF,#FF0000)">{{ value }}</p>
    {% elsif air_quality_facts.air_quality_level._value == 'Unhealthy for Sensitive Groups' %}
    <p style="background:linear-gradient(to right, #FFFFFF,#ffa500)">{{ value }}</p>
    {% elsif air_quality_facts.air_quality_level._value == 'Moderate' %}
    <p style="background:linear-gradient(to right, #FFFFFF,#eaea32)">{{ value }}</p>
    {% elsif air_quality_facts.air_quality_level._value == 'Good' %}
    <p style="background:linear-gradient(to right, #FFFFFF,#4ca64c)">{{ value }}</p>
    {% endif %};;

    }

    dimension: air_quality_sort {
      hidden: yes
      sql: CASE WHEN ${air_quality_level} = 'Good' THEN 1
                WHEN ${air_quality_level} = 'Moderate' THEN 2
                WHEN ${air_quality_level} = 'Unhealthy for Sensitive Groups' THEN 3
                WHEN ${air_quality_level} = 'Unhealthy' THEN 4
                WHEN ${air_quality_level} = 'Very Healthy' THEN 5
                WHEN ${air_quality_level} = 'Hazardous' THEN 6
                ELSE 7 END;;
    }

measure: average_aqi {
  label: "Average AQI"
  type: average
  value_format_name: decimal_2
  sql: ${Daily_Air_Quality_Index} ;;
  drill_fields: [detail*]
}

measure: percent_of_total {
  label: "% of Total Days"
  sql: CASE WHEN ${air_quality_level} = 'Good' THEN '65.6'
                WHEN ${air_quality_level} = 'Moderate' THEN '29'
                WHEN ${air_quality_level} = 'Unhealthy for Sensitive Groups' THEN '3.5'
                WHEN ${air_quality_level} = 'Unhealthy' THEN '.9'
                WHEN ${air_quality_level} = 'Very Healthy' THEN '.6'
                WHEN ${air_quality_level} = 'Hazardous' THEN '.4'
                ELSE 7 END ;;
                value_format_name: percent_1
                }


set: detail {
  fields: [created_date, AQI_Measurement_Devices.state, AQI_Measurement_Devices.city, device_id, Daily_Air_Quality_Index, AQI_Measurement_Devices.name]
}
}
