<%@ include file="/WEB-INF/template/include.jsp" %>
<%@ include file="/WEB-INF/template/header.jsp" %>

<%@ include file="template/localHeader.jsp" %>

<script type="text/javascript">

	var $j = jQuery.noConflict();

	function split(val) {
		if (jQuery.trim(val) === "")
			return new Array();
		return val.split(/,\s*/);
	}

	function extractLast(term) {
		return split(term).pop();
	}

	function valueExists(id, idList) {
		var ids = split(idList);
		for (i = 0; i < ids.length; i++)
			if (ids[i] == id)
				return true;
		return false;
	}

	$j(document).ready(function () {

		$j("#removeConcept").click(function () {
			// get the select list
			var list = document.getElementById("conceptList");
			// get the id list and then split them
			var idList = document.getElementById("conceptIds");
			var terms = split(idList.value);
			// remove selected element and then wipe out the associated id
			for (var i = 0; i < list.length; i++) {
				if (list.options[i].selected) {
					// remove the option element
					list.remove(i);
					// wipe out the id
					terms.splice(i, 1);
				}
			}
			idList.value = terms.join(",");
		});

		$j("#searchConcept").autocomplete({
			source:function (request, response) {
				jQuery.ajax({
					url:"${pageContext.request.contextPath}/module/odkconnector/search/concept.form",
					dataType:"json",
					data:{
						searchTerm:extractLast(request.term)
					},
					success:function (data) {
						response(jQuery.map(data.elements, function (item) {
							return {
								// see the json representation of the map
								label:item.name, value:item.id
							}
						}));
					}
				});
			},
			minLength:0,
			focus:function () {
				// prevent value inserted on focus
				return false;
			},
			select:function (event, ui) {
				var name = ui.item.label
				var id = ui.item.value;

				var list = document.getElementById("conceptList");
				var idList = document.getElementById("conceptIds");

				if (!valueExists(id, idList.value)) {
					// create the new option for the select
					var option = new Option(name, id);
					option.selected = true;
					list.options[list.options.length] = option;
					// add the new id into the concept id list
					var terms = split(idList.value);
					terms[terms.length] = id;
					idList.value = terms.join(",");
				}
				// clear out the field
				this.value = "";
				return false;
			}
		});
	})
</script>

<style type="text/css">

	#message {
		background-color: lightyellow;
	}

	fieldset {
		padding: 0;
		margin-bottom: 1em;
	}

	legend {
		margin-left: 1em;
		margin-left: 1em;
		color: #000000;
		font-weight: bold;
	}

	fieldset ol {
		padding: 0 0 1em 1em;
		list-style: none;
	}

	fieldset li {
		padding-bottom: 0.5em;
	}

	ol li label {
		display: block;
	}

	fieldset ul {
		padding: 0 0 0 0;
		list-style: none;
	}
</style>

<c:if test="${message != null}">
	<div id="message"><spring:message code="${message}" text="${message}"/></div>
</c:if>

<div>
	<form method="post">
		<fieldset>
			<ol>
				<li>
					<label for="conceptList"><spring:message code="odkconnector.manage.conceptList"/></label>
					<select id="conceptList" class="largeWidth" size="6" multiple="multiple">
						<c:forEach items="${concepts}" var="concept">
							<option value="${concept.conceptId}">${concept.name}</option>
						</c:forEach>
					</select>
					<input type="button" id="removeConcept" value="remove"/>
				</li>
				<li>
					<label for="searchConcept"><spring:message code="odkconnector.manage.conceptSearch"/></label>
					<input type="hidden" id="conceptIds" name="conceptIds" value="${conceptIds}"/>
					<input type="text" id="searchConcept" class="search" size="43"/>
				</li>
				<li><input type="submit" value="<spring:message code='odkconnector.manage.conceptSave' />"/></li>
			</ol>
		</fieldset>
	</form>
</div>


<%@ include file="/WEB-INF/template/footer.jsp" %>
