function randomId() {
  return 'v-' + Math.random().toString(36).slice(-8);
}

function prepareMxDbmsProductVue(data) {
  return new Vue({
    el: '#mx_dbms_product_form',
    data: data,
    methods: {
      addDataType: function() {
        this.$data.data_types.splice(0, 0, { id: randomId(), name: '', sizable: false, scalable: false, use_by_default: false });
      },
      removeDataType: function(dataType) {
        this.$data.data_types.$remove(dataType.$index);
      },
      duplicateDataType: function(dataType) {
        var base = dataType.$data.data_type;
        var newId = randomId();
        this.$data.data_types.splice(dataType.$index + 1, 0, { id: newId, name: '', sizable: base.sizable, scalable: base.scalable, use_by_default: base.use_by_default });
      },
      classFor: function(obj, prop) {
        return obj.errors && obj.errors[prop] ? 'mx-error' : '';
      }
    }
  });
}

function prepareMxCommonColumnSetVue(data) {
  return new Vue({
    el: '#mx_common_column_set_form',
    data: data,
    methods: {
      addHeaderColumn: function() {
        this.$data.header_columns.push({ id: randomId() });
      },
      addFooterColumn: function() {
        this.$data.footer_columns.push({ id: randomId() });
      },
      removeHeaderColumn: function(column) {
        this.$data.header_columns.$remove(column.$index);
      },
      removeFooterColumn: function(column) {
        this.$data.footer_columns.$remove(column.$index);
      },
      classFor: function(obj, prop) {
        return obj.errors && obj.errors[prop] ? 'mx-error' : '';
      }
    }
  });
}
