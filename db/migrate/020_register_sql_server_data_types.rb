class RegisterSqlServerDataTypes < ActiveRecord::Migration
  NAME = 'SQL Server'

  def up
    data_types = [
      { name: 'bigint'          , sizable: false, scalable: false, use_by_default: false },
      { name: 'int'             , sizable: false, scalable: false, use_by_default: true  },
      { name: 'smallint'        , sizable: false, scalable: false, use_by_default: false },
      { name: 'tinyint'         , sizable: false, scalable: false, use_by_default: false },
      { name: 'numeric'         , sizable: true , scalable: true , use_by_default: false },
      { name: 'decimal'         , sizable: true , scalable: true , use_by_default: true  },
      { name: 'smallmoney'      , sizable: false, scalable: false, use_by_default: false },
      { name: 'money'           , sizable: false, scalable: false, use_by_default: false },
      { name: 'float'           , sizable: false, scalable: false, use_by_default: true  },
      { name: 'real'            , sizable: false, scalable: false, use_by_default: true  },
      { name: 'bit'             , sizable: false, scalable: false, use_by_default: true  },
      { name: 'date'            , sizable: false, scalable: false, use_by_default: true  },
      { name: 'time'            , sizable: true , scalable: false, use_by_default: true  },
      { name: 'datetime'        , sizable: false, scalable: false, use_by_default: false },
      { name: 'datetime2'       , sizable: true , scalable: false, use_by_default: true  },
      { name: 'smalldatetime'   , sizable: false, scalable: false, use_by_default: false },
      { name: 'datetimeoffset'  , sizable: true , scalable: false, use_by_default: false },
      { name: 'char'            , sizable: true , scalable: false, use_by_default: true  },
      { name: 'varchar'         , sizable: true , scalable: false, use_by_default: true  },
      { name: 'text'            , sizable: false, scalable: false, use_by_default: true  },
      { name: 'binary'          , sizable: true , scalable: false, use_by_default: false },
      { name: 'varbinary'       , sizable: true , scalable: false, use_by_default: true  },
      { name: 'image'           , sizable: false, scalable: false, use_by_default: false },
      { name: 'timestamp'       , sizable: false, scalable: false, use_by_default: true  },
      { name: 'uniqueidentifier', sizable: false, scalable: false, use_by_default: true  }
    ]
    ActiveRecord::Base.transaction do
      db = MxDbms::SqlServer.create!(name: NAME, comment: "Builtin DBMS as #{NAME} type")
      data_types.each do |data_type|
        MxDataType.create!(data_type.merge(dbms_product_id: db.id))
      end
    end
  end

  def down
    MxDbms::SqlServer.where(name: NAME).first.destroy
  end
end

