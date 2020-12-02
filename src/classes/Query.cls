public with sharing class Query {

    public interface Condition {

    }

    public interface OrderBy {

    }

    public abstract class GroupCondition implements Condition {

        List<Condition> conditions;

        public GroupCondition addCondition(Condition condition) {
            if (this.conditions == null) {
                this.conditions = new List<Condition>();
            }

            this.conditions.add(condition);

            return this;
        }

        public override String toString() {
            if (this.conditions == null) return '';

            return '(' + this.concatConditions() + ')';
        }

        protected String concatConditions() {
            List<String> conditionStrings = new List<String>();
            for (Condition condition: this.conditions) {
                conditionStrings.add(condition.toString());
            }
            return String.join(conditionStrings, ' ' + this.getConcatOperator() + ' ');
        }

        protected abstract String getConcatOperator();
    }

    public virtual class AndCondition extends GroupCondition {
        protected override String getConcatOperator() {
            return 'AND';
        }
    }

    public virtual class OrCondition extends GroupCondition {
        protected override String getConcatOperator() {
            return 'OR';
        }
    }
}