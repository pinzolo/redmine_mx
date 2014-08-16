class RegisterPostgresqlDataTypes < ActiveRecord::Migration
  NAME = 'PostgreSQL'

  def up
    data_types = [
      { name: 'smallint'                , sizable: false, scalable: false, use_by_default: false },
      { name: 'integer'                 , sizable: false, scalable: false, use_by_default: true  },
      { name: 'bigint'                  , sizable: false, scalable: false, use_by_default: false },
      { name: 'decimal'                 , sizable: true , scalable: true , use_by_default: false },
      { name: 'numeric'                 , sizable: true , scalable: true , use_by_default: true  },
      { name: 'real'                    , sizable: false, scalable: false, use_by_default: true  },
      { name: 'double precision'        , sizable: false, scalable: false, use_by_default: true  },
      { name: 'serial'                  , sizable: false, scalable: false, use_by_default: true  },
      { name: 'bigserial'               , sizable: false, scalable: false, use_by_default: false },
      { name: 'money'                   , sizable: false, scalable: false, use_by_default: false },
      { name: 'char'                    , sizable: true , scalable: false, use_by_default: true  },
      { name: 'varchar'                 , sizable: true , scalable: false, use_by_default: true  },
      { name: 'text'                    , sizable: false, scalable: false, use_by_default: true  },
      { name: 'bytea'                   , sizable: false, scalable: false, use_by_default: true  },
      { name: 'timestamp'               , sizable: true , scalable: false, use_by_default: true  },
      { name: 'timestamp with time zone', sizable: true , scalable: false, use_by_default: false },
      { name: 'date'                    , sizable: false, scalable: false, use_by_default: true  },
      { name: 'time'                    , sizable: true , scalable: false, use_by_default: true  },
      { name: 'time with time zone'     , sizable: true , scalable: false, use_by_default: false },
      { name: 'interval'                , sizable: true , scalable: false, use_by_default: false },
      { name: 'boolean'                 , sizable: false, scalable: false, use_by_default: true  }
    ]
    ActiveRecord::Base.transaction do
      db = MxDbms::Postgresql.create!(name: NAME, comment: "Builtin DBMS as #{NAME} type")
      data_types.each do |data_type|
        MxDataType.create!(data_type.merge(dbms_product_id: db.id))
      end
    end
  end

  def down
    MxDbms::Postgresql.where(name: NAME).first.try(:destroy)
  end
end

