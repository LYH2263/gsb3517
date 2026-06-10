<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/views/admin/header.jsp"><jsp:param name="title" value="分类管理"/><jsp:param name="menu" value="categories"/></jsp:include>

<div class="d-flex justify-content-between align-items-center mb-3">
    <h4>分类管理</h4>
    <button class="btn btn-primary" onclick="openCategoryModal()">
        <i class="bi bi-plus-circle me-1"></i>添加分类
    </button>
</div>

<!-- 筛选栏 -->
<div class="card border-0 shadow-sm mb-3" style="border-radius:12px">
    <div class="card-body py-3">
        <div class="row g-2 align-items-end">
            <div class="col-md-4">
                <label class="form-label mb-1 small text-muted">搜索分类</label>
                <input type="text" class="form-control form-control-sm" id="catKeyword" placeholder="分类名称/描述" oninput="filterCategories()">
            </div>
        </div>
    </div>
</div>

<div class="card border-0 shadow-sm" style="border-radius:12px">
    <div class="table-responsive">
        <table class="table mb-0 align-middle">
            <thead class="table-light">
                <tr><th>ID</th><th>分类名称</th><th>描述</th><th>排序</th><th>操作</th></tr>
            </thead>
            <tbody>
                <c:forEach var="cat" items="${categories}">
                    <tr class="cat-row" data-name="${cat.name}" data-desc="${cat.description}">
                        <td>${cat.id}</td>
                        <td><strong>${cat.name}</strong></td>
                        <td class="text-muted">${cat.description}</td>
                        <td>${cat.sortOrder}</td>
                        <td>
                            <button class="btn btn-sm btn-outline-primary me-1"
                                    onclick="openCategoryModal(${cat.id}, '${cat.name}', '${cat.description}', ${cat.sortOrder})">
                                <i class="bi bi-pencil"></i>
                            </button>
                            <button class="btn btn-sm btn-outline-danger" onclick="deleteCategory(${cat.id})">
                                <i class="bi bi-trash"></i>
                            </button>
                        </td>
                    </tr>
                </c:forEach>
            </tbody>
        </table>
    </div>
</div>

<!-- 分类编辑Modal -->
<div class="modal fade" id="categoryModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content" style="border-radius:12px">
            <div class="modal-header">
                <h5 class="modal-title" id="categoryModalTitle">添加分类</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <form id="categoryForm">
                    <input type="hidden" name="id" id="catId">
                    <div class="mb-3">
                        <label class="form-label">分类名称 <span class="text-danger">*</span></label>
                        <input type="text" class="form-control" name="name" id="catName">
                    </div>
                    <div class="mb-3">
                        <label class="form-label">描述</label>
                        <input type="text" class="form-control" name="description" id="catDesc">
                    </div>
                    <div class="mb-3">
                        <label class="form-label">排序</label>
                        <input type="number" class="form-control" name="sortOrder" id="catSort" value="0">
                    </div>
                </form>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">取消</button>
                <button type="button" class="btn btn-primary" onclick="saveCategory()">保存</button>
            </div>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/views/admin/footer.jsp"/>
<script>
var categoryModal;
$(function() { categoryModal = new bootstrap.Modal(document.getElementById('categoryModal')); });

function openCategoryModal(id, name, desc, sort) {
    clearFormErrors('categoryForm');
    if (id) {
        $('#categoryModalTitle').text('编辑分类');
        $('#catId').val(id);
        $('#catName').val(name);
        $('#catDesc').val(desc);
        $('#catSort').val(sort);
    } else {
        $('#categoryModalTitle').text('添加分类');
        document.getElementById('categoryForm').reset();
        $('#catId').val('');
    }
    categoryModal.show();
}

function saveCategory() {
    var valid = validateForm('categoryForm', {
        name: { required: true, requiredMsg: '请输入分类名称' }
    });
    if (!valid) return;

    ajaxPost(contextPath + '/admin/category/save', $('#categoryForm').serialize(), function(resp) {
        if (resp.success) {
            showToast(resp.message, 'success');
            categoryModal.hide();
            setTimeout(function() { location.reload(); }, 800);
        } else {
            showToast(resp.message, 'error');
            if (resp.field) highlightField(resp.field);
        }
    });
}

function deleteCategory(id) {
    showConfirm('确定要删除该分类吗？如果分类下有商品，将无法删除。', function() {
        ajaxPost(contextPath + '/admin/category/delete', {id: id}, function(resp) {
            showToast(resp.message, resp.success ? 'success' : 'error');
            if (resp.success) setTimeout(function() { location.reload(); }, 800);
        });
    });
}

function filterCategories() {
    var kw = document.getElementById('catKeyword').value.toLowerCase();
    var rows = document.querySelectorAll('.cat-row');
    var visibleCount = 0;
    rows.forEach(function(row) {
        var name = (row.getAttribute('data-name') || '').toLowerCase();
        var desc = (row.getAttribute('data-desc') || '').toLowerCase();
        var show = !kw || name.indexOf(kw) >= 0 || desc.indexOf(kw) >= 0;
        row.style.display = show ? '' : 'none';
        if (show) visibleCount++;
    });
}
</script>
