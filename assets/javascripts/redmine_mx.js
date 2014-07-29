function randomId() {
  return 'v-' + Math.random().toString(36).slice(-8);
}

function prepareMxDbmsProductVue(data) {
  return new Vue({
    el: '#mx_dbms_product_form',
    data: data,
    methods: {
      addDataType: function() {
        this.$data.data_types.push({ id: randomId(), name: '', sizable: false, scalable: false, use_by_default: false });
      },
      removeDataType: function(dataType) {
        this.$data.data_types.$remove(dataType.$index);
      },
      duplicateDataType: function(dataType) {
        var data = dataType.$data.data_type;
        this.$data.data_types.splice(dataType.$index + 1, 0, { id: randomId(), name: data.name, sizable: data.sizable, scalable: data.scalable, use_by_default: data.use_by_default });
      }
    }
  });
}
