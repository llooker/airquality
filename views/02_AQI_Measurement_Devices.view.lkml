view: AQI_Measurement_Devices {
  sql_table_name: PUBLIC.USERS ;;

    dimension: id {
      primary_key: yes
      type: number
      sql: ${TABLE}.id ;;
      tags: ["user_id"]
    }

    dimension: first_name {
      hidden: yes
      sql: INITCAP(${TABLE}.first_name) ;;
    }

    dimension: last_name {
      hidden: yes
      sql: INITCAP(${TABLE}.last_name) ;;
    }

    dimension: name {
      label: "Device Manager Name"
      sql: ${first_name} || ' ' || ${last_name} ;;
    }
  drill_fields: [detail*]

    dimension: email {
      sql: ${TABLE}.email ;;
      tags: ["email"]

      action: {
        label: "Email Device Manager"
        url: "https://desolate-refuge-53336.herokuapp.com/posts"
        icon_url: "https://sendgrid.com/favicon.ico"
        param: {
          name: "some_auth_code"
          value: "abc123456"
        }
        form_param: {
          name: "Subject"
          required: yes
          default: "Question About Your AQI Device"
        }
        form_param: {
          name: "Body"
          type: textarea
          required: yes
          default:
          "Hi {{ users.first_name._value }},

          I've been noticing some unusual readings from your AQI device.
          Have you been experiencing any technical issues recently?

          Thanks!
          SMC Labs"
        }
      }
      required_fields: [name, first_name]
    }

    ## Demographics ##

    dimension: city {
      sql: ${TABLE}.city ;;
      drill_fields: [detail*]    }

    dimension: state {
      sql: ${TABLE}.state ;;
      map_layer_name: us_states
      drill_fields: [detail*]    }

    dimension: zip {
      type: zipcode
      sql: ${TABLE}.zip ;;
      drill_fields: [detail*]
    }

    dimension: country {
      map_layer_name: countries
      sql: CASE WHEN ${TABLE}.country = 'UK' THEN 'United Kingdom'
           ELSE ${TABLE}.country
           END
       ;;
      drill_fields: [detail*]
    }

    dimension: latitude {
      sql: ${TABLE}.latitude ;;
      hidden: yes
    }

    dimension: longitude {
      sql: ${TABLE}.longitude ;;
      hidden: yes
    }

    dimension: location {
      hidden: yes
      type: location
      sql_latitude: ${TABLE}.latitude ;;
      sql_longitude: ${TABLE}.longitude ;;
    }

    dimension: approx_latitude {
      type: number
      sql: round(${TABLE}.latitude,1) ;;
      hidden: yes
    }

    dimension: approx_longitude {
      type: number
      sql: round(${TABLE}.longitude,1) ;;
      hidden: yes
    }

  set: detail {
    fields: [air_quality_facts.created_date, AQI_Measurement_Devices.state, AQI_Measurement_Devices.city, air_quality_facts.device_id, air_quality_facts.Daily_Air_Quality_Index, AQI_Measurement_Devices.name]
  }
  }
