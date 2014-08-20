function randomId() {
  return 'v-' + Math.random().toString(36).slice(-8);
}

function findById(collection, id) {
  var obj;
  collection.forEach(function(item) {
    if (id && item.id.toString() === id.toString()) {
      obj = item;
    }
  });
  return obj;
}

function prepareMxDbmsProductVue(data) {
  return new Vue({
    el: '#mx_dbms_product_form',
    data: data,
    methods: {
      addDataType: function() {
        this.data_types.push({ id: randomId() });
      },
      removeDataType: function(dataType) {
        this.data_types.$remove(dataType.$index);
      },
      insertDataType: function(dataType) {
        this.data_types.splice(dataType.$index, 0, { id: randomId() });
      },
      classFor: function(obj, prop) {
        return obj.errors && obj.errors[prop] ? 'mx-error' : '';
      }
    }
  });
}

function prepareMxColumnSetVue(data) {
  return new Vue({
    el: '#mx_column_set_form',
    data: data,
    methods: {
      addHeaderColumn: function() {
        this.header_columns.push({ id: randomId() });
      },
      addFooterColumn: function() {
        this.footer_columns.push({ id: randomId() });
      },
      removeHeaderColumn: function(column) {
        this.header_columns.$remove(column.$index);
      },
      removeFooterColumn: function(column) {
        this.footer_columns.$remove(column.$index);
      },
      classFor: function(obj, prop) {
        return obj.errors && obj.errors[prop] ? 'mx-error' : '';
      },
      getDataType: function(dataTypeId) {
        return findById(this.data_types, dataTypeId);
      },
      sizeEditable: function(obj) {
        var dataType = this.getDataType(obj.$data.column.data_type_id);
        return dataType && dataType.sizable;
      },
      scaleEditable: function(obj) {
        var dataType = this.getDataType(obj.$data.column.data_type_id);
        return dataType && dataType.scalable;
      },
      changeDataType: function(obj) {
        if (!this.sizeEditable(obj)) {
          obj.$data.column.size = null;
        }
        if (!this.scaleEditable(obj)) {
          obj.$data.column.scale = null;
        }
      }
    }
  });
}

function prepareMxTableVue(data) {
  return new Vue({
    el: '#mx_table_form',
    data: data,
    computed: {
      headerColumns: {
        $get: function() {
          var columnSet = findById(this.column_sets, this.column_set_id);
          return columnSet ? columnSet.header_columns : [];
        }
      },
      footerColumns: {
        $get: function() {
          var columnSet = findById(this.column_sets, this.column_set_id);
          return columnSet ? columnSet.footer_columns : [];
        }
      }
    },
    methods: {
      addColumn: function() {
        this.table_columns.push({ id: randomId() });
      },
      removeColumn: function(column) {
        this.table_columns.$remove(column.$index);
      },
      classFor: function(obj, prop) {
        return obj.errors && obj.errors[prop] ? 'mx-error' : '';
      },
      getDataType: function(dataTypeId) {
        return findById(this.$data.data_types, dataTypeId);
      },
      sizeEditable: function(obj) {
        var dataType = this.getDataType(obj.$data.column.data_type_id);
        return dataType && dataType.sizable;
      },
      scaleEditable: function(obj) {
        var dataType = this.getDataType(obj.$data.column.data_type_id);
        return dataType && dataType.scalable;
      },
      changeDataType: function(obj) {
        if (!this.sizeEditable(obj)) {
          obj.$data.column.size = null;
        }
        if (!this.scaleEditable(obj)) {
          obj.$data.column.scale = null;
        }
      }
    }
  });
}
