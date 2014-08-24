var mx = {
  randomId: function() {
    return 'v-' + Math.random().toString(36).slice(-8);
  },
  findById: function(collection, id) {
    if (!id) { return null; }
    if (!collection) { return null; }

    var obj;
    collection.forEach(function(item) {
      if (item.id.toString() === id.toString()) {
        obj = item;
      }
    });
  return obj;
  }
};

function prepareMxDbmsProductVue(data) {
  return new Vue({
    el: '#mx_dbms_product_form',
    data: data,
    methods: {
      addDataType: function() {
        this.data_types.push({ id: mx.randomId() });
      },
      removeDataType: function(dataType) {
        this.data_types.$remove(dataType.$index);
      },
      insertDataType: function(dataType) {
        this.data_types.splice(dataType.$index, 0, { id: mx.randomId() });
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
        this.header_columns.push({ id: mx.randomId() });
      },
      addFooterColumn: function() {
        this.footer_columns.push({ id: mx.randomId() });
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
        return mx.findById(this.data_types, dataTypeId);
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

function prepareMxTableVue(data, $) {
  data.editingPrimaryKey = data.primary_key.column_ids.length > 0;
  return new Vue({
    el: '#mx_table_form',
    data: data,
    computed: {
      headerColumns: function() {
        var columnSet = mx.findById(this.column_sets, this.column_set_id);
        return columnSet ? columnSet.header_columns : [];
      },
      footerColumns: function() {
        var columnSet = mx.findById(this.column_sets, this.column_set_id);
        return columnSet ? columnSet.footer_columns : [];
      },
      columns: function() {
        return $.merge($.merge($.merge([], this.headerColumns), this.table_columns), this.footerColumns);
      },
      primaryKeySelectableColumnIds: function() {
        var allColumnIds = $.map(this.columns, function(column) { return column.id.toString(); });
        var selectedColumnIds = this.primary_key.column_ids;
        return $.grep(allColumnIds, function(columnId) {
          return $.inArray(columnId.toString(), selectedColumnIds) < 0;
        });
      },
    },
    methods: {
      addColumn: function() {
        this.table_columns.push({ id: mx.randomId() });
      },
      insertColumn: function(column) {
        this.table_columns.splice(column.$index, 0, { id: mx.randomId() });
      },
      removeColumn: function(column) {
        this.table_columns.$remove(column.$index);
      },
      upColumn: function(column) {
        this.table_columns.$remove(column.$index);
        this.table_columns.splice(column.$index - 1, 0, column.$data.column);
      },
      downColumn: function(column) {
        this.table_columns.$remove(column.$index);
        this.table_columns.splice(column.$index + 1, 0, column.$data.column);
      },
      classFor: function(obj, prop) {
        return obj.errors && obj.errors[prop] ? 'mx-error' : '';
      },
      getColumn: function(columnId) {
        return mx.findById(this.columns, columnId);
      },
      getDataType: function(dataTypeId) {
        return mx.findById(this.data_types, dataTypeId);
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
      },
      editPrimaryKey: function() {
        this.editingPrimaryKey = true;
      },
      deletePrimaryKey: function() {
        this.editingPrimaryKey = false;
        this.primary_key.column_ids = [];
      },
      addToPrimaryKey: function(columnId) {
        this.primary_key.column_ids.push(columnId.$data.columnId);
      },
      removeFromPrimaryKey: function(columnId) {
        this.primary_key.column_ids.$remove(columnId.$index);
      },
      upPrimaryKeyColumn: function(columnId) {
        this.primary_key.column_ids.$remove(columnId.$index);
        this.primary_key.column_ids.splice(columnId.$index - 1, 0, columnId.$data.columnId);
      },
      downPrimaryKeyColumn: function(columnId) {
        this.primary_key.column_ids.$remove(columnId.$index);
        this.primary_key.column_ids.splice(columnId.$index + 1, 0, columnId.$data.columnId);
      }
    }
  });
}
