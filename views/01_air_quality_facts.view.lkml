view: air_quality_facts {
  sql_table_name: PUBLIC.ORDER_ITEMS ;;

dimension: id {
  primary_key: yes
  type: number
  sql: ${TABLE}.id ;;
}

dimension: inventory_item_id {
  type: number
  hidden: yes
  sql: ${TABLE}.inventory_item_id ;;
}

dimension: user_id {
  type: number
  hidden: yes
  sql: ${TABLE}.user_id ;;
}

measure: count {
  type: count_distinct
  sql: ${id} ;;
  drill_fields: [detail*]
}

measure: order_count {
  view_label: "Orders"
  type: count_distinct
  drill_fields: [detail*]
  sql: ${order_id} ;;
}


measure: count_last_28d {
  label: "Count Sold in Trailing 28 Days"
  type: count_distinct
  sql: ${id} ;;
  hidden: yes
  filters:
  {field:created_date
    value: "28 days"
  }}

dimension: order_id {
  type: number
  sql: ${TABLE}.order_id ;;


  action: {
    label: "Send this to slack channel"
    url: "https://hooks.zapier.com/hooks/catch/1662138/tvc3zj/"

    param: {
      name: "user_dash_link"
      value: "https://demo.looker.com/dashboards/160?Email={{ users.email._value}}"
    }

    form_param: {
      name: "Message"
      type: textarea
      default: "Hey,
      Could you check out order #{{value}}. It's saying its {{status._value}},
      but the customer is reaching out to us about it.
      ~{{ _user_attributes.first_name}}"
    }

    form_param: {
      name: "Recipient"
      type: select
      default: "zevl"
      option: {
        name: "zevl"
        label: "Zev"
      }
      option: {
        name: "slackdemo"
        label: "Slack Demo User"
      }

    }

    form_param: {
      name: "Channel"
      type: select
      default: "cs"
      option: {
        name: "cs"
        label: "Customer Support"
      }
      option: {
        name: "general"
        label: "General"
      }
    }
  }
}

########## Time Dimensions ##########

dimension_group: returned {
  type: time
  timeframes: [time, date, week, month, raw]
  sql: ${TABLE}.returned_at ;;
}

dimension_group: shipped {
  type: time
  timeframes: [date, week, month, raw]
  sql: ${TABLE}.shipped_at ;;
}

dimension_group: delivered {
  type: time
  timeframes: [date, week, month, raw]
  sql: ${TABLE}.delivered_at ;;
}

dimension_group: created {
  type: time
  timeframes: [time, hour, date, week, month, year, hour_of_day, day_of_week, month_num, month_name, raw, week_of_year]
  sql: ${TABLE}.created_at ;;
}

dimension: reporting_period {
  group_label: "Order Date"
  sql: CASE
        WHEN date_part('year',${created_raw}) = date_part('year',current_date)
        AND ${created_raw} < CURRENT_DATE
        THEN 'This Year to Date'

        WHEN date_part('year',${created_raw}) + 1 = date_part('year',current_date)
        AND date_part('dayofyear',${created_raw}) <= date_part('dayofyear',current_date)
        THEN 'Last Year to Date'

      END
       ;;
}

dimension: days_since_sold {
  hidden: yes
  sql: datediff('day',${created_raw},CURRENT_DATE) ;;
}

dimension: months_since_signup {
  view_label: "Orders"
  type: number
  sql: DATEDIFF('month',${users.created_raw},${created_raw}) ;;
}

########## Logistics ##########

dimension: status {
  sql: ${TABLE}.status ;;
}

dimension: days_to_process {
  type: number
  sql: CASE
        WHEN ${status} = 'Processing' THEN DATEDIFF('day',${created_raw},current_date)*1.0
        WHEN ${status} IN ('Shipped', 'Complete', 'Returned') THEN DATEDIFF('day',${created_raw},${shipped_raw})*1.0
        WHEN ${status} = 'Cancelled' THEN NULL
      END
       ;;
}

dimension: shipping_time {
  type: number
  sql: datediff('day',${shipped_raw},${delivered_raw})*1.0 ;;
}

measure: average_days_to_process {
  type: average
  value_format_name: decimal_2
  sql: ${days_to_process} ;;
}

measure: average_shipping_time {
  type: average
  value_format_name: decimal_2
  sql: ${shipping_time} ;;
}

########## Financial Information ##########

dimension: Daily_Air_Quality_Index {
  type: number
  value_format_name: usd
  sql: ${TABLE}.sale_price ;;
}

dimension: gross_margin {
  type: number
  value_format_name: usd
  sql: ${Daily_Air_Quality_Index} - ${inventory_items.cost} ;;
}


measure: total_sale_price {
  type: sum
  value_format_name: usd
  sql: ${Daily_Air_Quality_Index} ;;
  drill_fields: [detail*]
}

  dimension: average_air_quality {
    sql: CASE WHEN ${Daily_Air_Quality_Index} > 300 then 'Hazardous'
          WHEN ${Daily_Air_Quality_Index} > 200 then 'Very Unhealthy'
          WHEN ${Daily_Air_Quality_Index} > 150 then 'Unhealthy'
          WHEN ${Daily_Air_Quality_Index} > 100 then 'Unhealthy for Sensitive Groups'
          WHEN ${Daily_Air_Quality_Index} > 50 then 'Moderate'
          ELSE 'Good' END;;
    html: {% if order_items.average_air_quality._value == 'Hazardous' %}
    <p style="background:linear-gradient(to right, #FFFFFF, #800000)">{{ value }}</p>
    {% elsif order_items.average_air_quality._value == 'Very Unhealthy' %}
    <p style="background:linear-gradient(to right, #FFFFFF,#DA70D6)">{{ value }}</p>
    {% elsif order_items.average_air_quality._value == 'Unhealthy' %}
    <p style="background:linear-gradient(to right, #FFFFFF,#FF0000)">{{ value }}</p>
    {% elsif order_items.average_air_quality._value == 'Unhealthy for Sensitive Groups' %}
    <p style="background:linear-gradient(to right, #FFFFFF,#ffa500)">{{ value }}</p>
    {% elsif order_items.average_air_quality._value == 'Moderate' %}
    <p style="background:linear-gradient(to right, #FFFFFF,#eaea32)">{{ value }}</p>
    {% elsif order_items.average_air_quality._value == 'Good' %}
    <p style="background:linear-gradient(to right, #FFFFFF,#4ca64c)">{{ value }}</p>
    {% endif %};;
    }


measure: total_gross_margin {
  type: sum
  value_format_name: usd
  sql: ${gross_margin} ;;
  drill_fields: [detail*]
}

measure: average_sale_price {
  type: average
  value_format_name: usd
  sql: ${Daily_Air_Quality_Index} ;;
  drill_fields: [detail*]
}

measure: median_sale_price {
  type: median
  value_format_name: usd
  sql: ${Daily_Air_Quality_Index} ;;
  drill_fields: [detail*]
}

measure: average_gross_margin {
  type: average
  value_format_name: usd
  sql: ${gross_margin} ;;
  drill_fields: [detail*]
}

measure: total_gross_margin_percentage {
  type: number
  value_format_name: percent_2
  sql: 1.0 * ${total_gross_margin}/ NULLIF(${total_sale_price},0) ;;
}

measure: average_spend_per_user {
  type: number
  value_format_name: usd
  sql: 1.0 * ${total_sale_price} / NULLIF(${users.count},0) ;;
  drill_fields: [detail*]
}

########## Return Information ##########

dimension: is_returned {
  type: yesno
  sql: ${returned_raw} IS NOT NULL ;;
}

measure: returned_count {
  type: count_distinct
  sql: ${id} ;;
  filters: {
    field: is_returned
    value: "yes"
  }
  drill_fields: [detail*]
}

measure: returned_total_sale_price {
  type: sum
  value_format_name: usd
  sql: ${Daily_Air_Quality_Index} ;;
  filters: {
    field: is_returned
    value: "yes"
  }
}

measure: return_rate {
  type: number
  value_format_name: percent_2
  sql: 1.0 * ${returned_count} / nullif(${count},0) ;;
}



########## Dynamic Sales Cohort App ##########

filter: cohort_by {
  type: string
  hidden: yes
  suggestions: ["Week", "Month", "Quarter", "Year"]
}

filter: metric {
  type: string
  hidden: yes
  suggestions: ["Order Count", "Gross Margin", "Total Sales", "Unique Users"]
}

dimension_group: first_order_period {
  type: time
  timeframes: [date]
  hidden: yes
  sql: CAST(DATE_TRUNC({% parameter cohort_by %}, ${user_order_facts.first_order_date}) AS DATE)
    ;;
}

dimension: periods_as_customer {
  type: number
  hidden: yes
  sql: DATEDIFF({% parameter cohort_by %}, ${user_order_facts.first_order_date}, ${user_order_facts.latest_order_date})
    ;;
}

measure: cohort_values_0 {
  type: count_distinct
  hidden: yes
  sql: CASE WHEN {% parameter metric %} = 'Order Count' THEN ${id}
        WHEN {% parameter metric %} = 'Unique Users' THEN ${users.id}
        ELSE null
      END
       ;;
}

measure: cohort_values_1 {
  type: sum
  hidden: yes
  sql: CASE WHEN {% parameter metric %} = 'Gross Margin' THEN ${gross_margin}
        WHEN {% parameter metric %} = 'Total Sales' THEN ${Daily_Air_Quality_Index}
        ELSE 0
      END
       ;;
}

measure: values {
  type: number
  hidden: yes
  sql: ${cohort_values_0} + ${cohort_values_1} ;;
}




########## Sets ##########

set: detail {
  fields: [id, order_id, status, created_date, Daily_Air_Quality_Index, products.brand, products.item_name, users.portrait, users.name, users.email]
}
set: return_detail {
  fields: [id, order_id, status, created_date, returned_date, Daily_Air_Quality_Index, products.brand, products.item_name, users.portrait, users.name, users.email]
}
}
