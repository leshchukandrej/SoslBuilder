public with sharing class SoslBuilder {

    private static final String ALL_FIELDS = 'ALL FIELDS';
    private static final String EMAIL_FIELDS = 'EMAIL FIELDS';
    private static final String NAME_FIELDS = 'NAME FIELDS';
    private static final String PHONE_FIELDS = 'PHONE FIELDS';
    private static final String SIDEBAR_FIELDS = 'SIDEBAR FIELDS';

    private static final Set<String> AVAILABLE_FIND_IN_TYPES = new Set<String>{
        ALL_FIELDS,
        EMAIL_FIELDS,
        NAME_FIELDS,
        PHONE_FIELDS,
        SIDEBAR_FIELDS
    };

    private static final String EMPTY_SEARCH_TERM_ERROR = 'Search term can\'t be empty';
    private static final String INCORRECT_SEARCH_IN_TYPE_ERROR = 'Incorrect "Search in" type';
    private static final String FIELDS_ALREADY_SET_ERROR = 'Fields are already set';
    private static final String WHERE_CONDITION_ALREADY_SET_ERROR = 'WHERE Conditions are already set';

    private String searchString;
    private String inx;
    private Map<String, ReturningObject> returningObjectBySObjectName;

    public Inx find(Condition condition) {
        if (condition == null) throw new SoslException(EMPTY_SEARCH_TERM_ERROR);

        this.searchString = condition.toString();
        return new Inx(this);
    }

    public Inx find(String searchString) {
        if (String.isEmpty(searchString)) throw new SoslException(EMPTY_SEARCH_TERM_ERROR);

        this.searchString = searchString;
        return new Inx(this);
    }

    public override String toString() {
        return this.toSosl();
    }

    private FirstReturning inx(String inx) {
        this.inx = inx;
        return new FirstReturning(this);
    }

    private void addReturningObjects(List<ReturningObject> returningObjects) {
        if (this.returningObjectBySObjectName == null) this.returningObjectBySObjectName = new Map<String, ReturningObject>();

        for (ReturningObject returningObject: returningObjects) {
            returningObjectBySObjectName.put(returningObject.sObjectName, returningObject);
        }
    }

    private List<List<SObject>> toRecords() {
        String soslQuery = this.toSosl();
        System.debug( soslQuery );
        return Search.query(soslQuery);
    }

    private Map<String, List<SObject>> toRecordsBySObjectName() {
        Map<String, List<SObject>> sObjectsBySObjectName = new Map<String, List<SObject>>();
        for (List<SObject> sObjects : this.toRecords()) {
            sObjectsBySObjectName.put(sObjects.getSObjectType().getDescribe().getName(), sObjects);
        }
        return sObjectsBySObjectName;
    }

    private String toSosl() {
        String sosl = '';

        sosl += 'FIND {' + this.searchString + '} ';
        sosl += 'IN ' + this.inx + ' ';
        sosl += 'RETURNING ' + this.getReturning();

        return sosl;
    }

    private String getReturning() {
        List<String> returningList = new List<String>();
        for (ReturningObject returningObject: this.returningObjectBySObjectName.values()) {
            returningList.add(returningObject.toString());
        }
        return String.join(returningList, ', ');
    }


    public class Inx {

        private SoslBuilder soslBuilder;

        private Inx(SoslBuilder soslBuilder) {
            this.soslBuilder = soslBuilder;
        }

        public FirstReturning inx(String findType) {
            if (String.isEmpty(findType)) {
                return this.soslBuilder.inx(ALL_FIELDS);
            } else if (AVAILABLE_FIND_IN_TYPES.contains(findType)) {
                return this.soslBuilder.inx(findType);
            }

            throw new SoslException(INCORRECT_SEARCH_IN_TYPE_ERROR);
        }

        public FirstReturning inAllFields() {
            return this.soslBuilder.inx(ALL_FIELDS);
        }

        public FirstReturning inEmailFields() {
            return this.soslBuilder.inx(EMAIL_FIELDS);
        }

        public FirstReturning inNameFields() {
            return this.soslBuilder.inx(NAME_FIELDS);
        }

        public FirstReturning inPhoneFields() {
            return this.soslBuilder.inx(PHONE_FIELDS);
        }

        public FirstReturning inSidebarFields() {
            return this.soslBuilder.inx(SIDEBAR_FIELDS);
        }
    }

    public virtual class FirstReturning {
        private SoslBuilder soslBuilder;

        private FirstReturning(SoslBuilder soslBuilder) {
            this.soslBuilder = soslBuilder;
        }

        public Returning addReturningObject(String sObjectName) {
            return this.addReturningObjects(new Set<String>{sObjectName});
        }

        public Returning addReturningObjects(Set<String> sObjectNames) {
            List<ReturningObject> returningObjects = new List<ReturningObject>();
            for (String sObjectName: sObjectNames) {
                returningObjects.add(new ReturningObject(sObjectName));
            }
            return this.addReturningObjects(returningObjects);
        }

        public Returning addReturningObject(ReturningObject returningObject) {
            return this.addReturningObjects(new List<ReturningObject>{returningObject});
        }

        public Returning addReturningObjects(List<ReturningObject> returningObjects) {
            this.getSoslBuilder().addReturningObjects(returningObjects);
            return new Returning(this.soslBuilder);
        }

        protected SoslBuilder getSoslBuilder() {
            return this.soslBuilder;
        }
    }

    public class Returning extends FirstReturning {

        private Returning(SoslBuilder soslBuilder) {
            super(soslBuilder);
        }

        public List<List<SObject>> toRecords() {
            return this.getSoslBuilder().toRecords();
        }

        public Map<String, List<SObject>> toRecordsBySObjectName() {
            return this.getSoslBuilder().toRecordsBySObjectName();
        }

        public override String toString() {
            return this.getSoslBuilder().toSosl();
        }
    }

    public class ReturningObject {

        private String sObjectName;
        private Set<String> fields;
        private String listView;
        private String wherex;
        private String orderBy;
        private Integer limitx;
        private Integer offset;

        public ReturningObject(String sObjectName) {
            this.sObjectName = sObjectName;
        }

        public ReturningObject fields(String field) {
            return this.fields(new Set<String>{field});
        }

        public ReturningObject fields(Set<String> fields) {
            if (this.fields != null)  throw new SoslException(FIELDS_ALREADY_SET_ERROR);

            this.fields = fields;
            return this;
        }

        public ReturningObject listView(String listView) {
            this.listView = listView;
            return this;
        }

        public ReturningObject wherex(Query.Condition condition) {
            return this.wherex(condition.toString());
        }

        public ReturningObject wherex(String whereCondition) {
            if (this.wherex != null) throw new SoslException(WHERE_CONDITION_ALREADY_SET_ERROR);

            this.wherex = whereCondition;
            return this;
        }

        public ReturningObject orderBy(Query.OrderBy orderBy) {
            this.orderBy = orderBy.toString();
            return this;
        }

        public ReturningObject orderBy(String orderBy) {
            this.orderBy = orderBy;
            return this;
        }

        public ReturningObject limitx(Integer limitx) {
            this.limitx = limitx;
            return this;
        }

        public ReturningObject offset(Integer offset) {
            this.offset = offset;
            return this;
        }

        public override String toString() {
            String sosl = this.sObjectName;

            if (this.hasAdditionalParams()) {
                sosl += '(';
                sosl += this.getFields();
                sosl += this.getListView();
                sosl += this.getWhere();
                sosl += this.getOrderBy();
                sosl += this.getLimit();
                sosl += this.getOffset();
                sosl += ')';
            }

            return sosl;
        }

        private String getFields() {
            if (!hasFields()) return '';

            return String.join(new List<String>(this.fields), ', ');
        }

        private String getListView() {
            if (String.isEmpty(this.listView)) return '';

            return ' USING LISTVIEW = ' + this.listView;
        }

        private String getWhere() {
            if (String.isEmpty(this.wherex)) return '';

            return ' WHERE ' + this.wherex;
        }

        private String getOrderBy() {
            if (String.isEmpty(this.orderBy)) return '';

            return ' ORDER BY ' + this.orderBy;
        }

        private String getLimit() {
            if (this.limitx == null) return '';

            return ' LIMIT ' + this.limitx;
        }

        private String getOffset() {
            if (this.offset == null) return '';

            return ' OFFSET ' + this.offset;
        }

        private Boolean hasAdditionalParams() {
            return this.hasFields()
                || String.isNotEmpty(this.listView)
                || String.isNotEmpty(this.wherex)
                || String.isNotEmpty(this.orderBy)
                || this.limitx != null
                || this.offset != null;
        }

        private Boolean hasFields() {
            return this.fields != null && !this.fields.isEmpty();
        }
    }

    public interface Condition {

    }

    public class SearchCondition implements Condition, Query.Condition {

        String searchTerm;

        public SearchCondition(String searchTerm) {
            this.searchTerm = searchTerm;
        }

        public override String toString() {
            if (String.isEmpty(this.searchTerm)) throw new SoslException(EMPTY_SEARCH_TERM_ERROR);

            return '"' + this.searchTerm + '"';
        }
    }

    public abstract class GroupCondition extends Query.GroupCondition implements Condition {
        public GroupCondition addSearchCondition(Condition condition) {
            this.addCondition((Query.Condition) condition);
            return this;
        }
    }

    public class AndCondition extends GroupCondition {
        protected override String getConcatOperator() {
            return 'AND';
        }
    }

    public class OrCondition extends GroupCondition {
        protected override String getConcatOperator() {
            return 'OR';
        }
    }

    private class SoslException extends Exception {

    }
}