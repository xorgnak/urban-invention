//
// nomadic -> node firmware v0.0.1a
// 
// provides basic ap configuration for network access point, local access point, and secondary device interaction.
//
// [install]
// 1. install the esp8266-framework library including it's dependancies.
// 2. upload this sketch to an esp8266.
// 3. connect to esp8266 ap.
// 4. navagate to 192.168.0.1
// 5. signin with esp8266Stack/espstack@8266
// 6. note client id under mqtt general settings.
// 7.a. configure network ssid and password under wifi settings.
// 7.b. configure local ssid and password for network sharing.
// 7.c. submit.
// 8. put the client id from above into the input bar at vango.me to being controling your device.
// 
// [usage]
//- [X] wifi extender.
//- [X] mqtt broker.
//- [X] ota updates.
//- [X] helpful web ui.
//- [ ] neopixel integration.

#include <EwingsEsp8266Stack.h>
#define ENABLE_DYNAMIC_SUBNETING
#define NAPT_INIT_DURATION_AFTER_WIFI_CONNECT MILLISECOND_DURATION_5000
int state = 0;

void publish_callback( char* _payload, uint16_t _length ){

  memset( _payload, 0, _length );

  String _data_to_publish = "";
  _data_to_publish += "{\"node\":[mac], \"db\":";
  // json doc
  _data_to_publish += ", \"state\":";
  _data_to_publish += state;
  _data_to_publish += "}";
  _data_to_publish.toCharArray( _payload, _length );
}

// mqtt service will call this function whenever it receive data on subscribed topic
void subscribe_callback( uint32_t *args, const char* topic, uint32_t topic_len, const char *data, uint32_t data_len ){

  char *topicBuf = new char[topic_len+1], *dataBuf = new char[data_len+1];
  memcpy(topicBuf, topic, topic_len);
  topicBuf[topic_len] = 0;
  memcpy(dataBuf, data, data_len);
  dataBuf[data_len] = 0;
  Serial.printf("MQTT: user Receive topic: %s, data: %s \n\n", topicBuf, dataBuf);
  delete[] topicBuf; delete[] dataBuf;
}

void nomadic(){
  mqtt_general_config_table _mqtt_general_configs = __database_service.get_mqtt_general_config_table();
  mqtt_pubsub_config_table _mqtt_pubsub_configs = __database_service.get_mqtt_pubsub_config_table();
  mqtt_lwt_config_table _mqtt_lwt_configs = __database_service.get_mqtt_lwt_config_table();
  memcpy( _mqtt_general_configs.host, "vango.me", strlen( "vango.me" ) );
  _mqtt_general_configs.port = 1883;
  _mqtt_general_configs.keepalive = 60;
  memcpy( _mqtt_pubsub_configs.publish_topics[0].topic, "hub", strlen( "hub" ) );
  _mqtt_pubsub_configs.publish_topics[0].qos = 0;
  memcpy( _mqtt_pubsub_configs.subscribe_topics[0].topic, String(ESP.getChipId()).c_str(), strlen( String(ESP.getChipId()).c_str() ) );
  _mqtt_pubsub_configs.subscribe_topics[0].qos = 0;
  _mqtt_pubsub_configs.publish_frequency = 5;
  memcpy( _mqtt_lwt_configs.will_topic, "hub", strlen( "hub" ) );
  memcpy( _mqtt_lwt_configs.will_message, "[mac]", strlen( "[mac]" ) );
  _mqtt_lwt_configs.will_qos = 0;
  __database_service.set_mqtt_general_config_table( &_mqtt_general_configs );
  __database_service.set_mqtt_lwt_config_table( &_mqtt_lwt_configs );
  __database_service.set_mqtt_pubsub_config_table( &_mqtt_pubsub_configs );
  __mqtt_service.setMqttPublishDataCallback( publish_callback );
  __mqtt_service.setMqttSubscribeDataCallback( subscribe_callback );
  __task_scheduler.setTimeout( [&]() { __mqtt_service.handleMqttConfigChange(); }, 10 );
}


void setup() {
  EwStack.initialize();
  nomadic();
}

void loop() {
  EwStack.serve();
}
