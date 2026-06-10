<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/views/admin/header.jsp"><jsp:param name="title" value="${empty product ? '添加商品' : '编辑商品'}"/><jsp:param name="menu" value="products"/></jsp:include>

<div class="d-flex align-items-center mb-3">
    <a href="${pageContext.request.contextPath}/admin/products" class="btn btn-outline-secondary me-3">
        <i class="bi bi-arrow-left"></i>
    </a>
    <h4 class="mb-0">${empty product ? '添加商品' : '编辑商品'}</h4>
</div>

<div class="card border-0 shadow-sm" style="border-radius:12px;max-width:700px">
    <div class="card-body p-4">
        <form id="productForm">
            <c:if test="${not empty product}">
                <input type="hidden" name="id" value="${product.id}">
            </c:if>
            <div class="mb-3">
                <label class="form-label">商品名称 <span class="text-danger">*</span></label>
                <input type="text" class="form-control" name="name" value="${product.name}">
            </div>
            <div class="mb-3">
                <label class="form-label">商品分类 <span class="text-danger">*</span></label>
                <select class="form-select" name="categoryId">
                    <option value="">请选择分类</option>
                    <c:forEach var="cat" items="${categories}">
                        <option value="${cat.id}" ${product.categoryId == cat.id ? 'selected' : ''}>${cat.name}</option>
                    </c:forEach>
                </select>
            </div>
            <div class="row mb-3">
                <div class="col-md-6">
                    <label class="form-label">价格 <span class="text-danger">*</span></label>
                    <input type="number" class="form-control" name="price" step="0.01" value="${product.price}">
                </div>
                <div class="col-md-6">
                    <label class="form-label">库存 <span class="text-danger">*</span></label>
                    <input type="number" class="form-control" name="stock" value="${product.stock != null ? product.stock : 0}">
                </div>
            </div>
            <div class="mb-3">
                <label class="form-label">商品图片</label>
                <input type="hidden" name="image" id="imageInput" value="${product.image}">
                <div class="image-upload-area" id="uploadArea">
                    <c:choose>
                        <c:when test="${not empty product.image}">
                            <img id="imagePreview" src="${pageContext.request.contextPath}${product.image}" alt="商品图片" class="image-preview-img">
                            <div class="image-upload-overlay" id="uploadOverlay">
                                <i class="bi bi-camera"></i>
                                <span>更换图片</span>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div class="image-upload-placeholder" id="uploadPlaceholder">
                                <i class="bi bi-cloud-arrow-up"></i>
                                <span>点击或拖拽上传图片</span>
                                <small>支持 JPG、PNG、GIF、WebP，最大 5MB</small>
                            </div>
                            <img id="imagePreview" src="" alt="" class="image-preview-img" style="display:none">
                            <div class="image-upload-overlay" id="uploadOverlay" style="display:none">
                                <i class="bi bi-camera"></i>
                                <span>更换图片</span>
                            </div>
                        </c:otherwise>
                    </c:choose>
                    <input type="file" id="fileInput" accept="image/*" style="display:none">
                    <div class="upload-progress" id="uploadProgress" style="display:none">
                        <div class="upload-progress-bar" id="uploadProgressBar"></div>
                    </div>
                </div>
                <div class="image-upload-actions mt-2" id="imageActions" style="display:${not empty product.image ? 'flex' : 'none'}">
                    <button type="button" class="btn btn-sm btn-outline-danger" id="removeImageBtn">
                        <i class="bi bi-trash me-1"></i>删除图片
                    </button>
                </div>
            </div>
            <div class="mb-3">
                <label class="form-label">商品描述</label>
                <textarea class="form-control" name="description" rows="4">${product.description}</textarea>
            </div>
            <div class="mb-3">
                <label class="form-label">状态</label>
                <select class="form-select" name="status">
                    <option value="1" ${product.status == 1 || empty product ? 'selected' : ''}>上架</option>
                    <option value="0" ${product.status == 0 ? 'selected' : ''}>下架</option>
                </select>
            </div>
            <button type="submit" class="btn btn-primary">
                <i class="bi bi-check-circle me-1"></i>保存
            </button>
        </form>
    </div>
</div>

<jsp:include page="/WEB-INF/views/admin/footer.jsp"/>
<script>
(function() {
    var uploadArea = document.getElementById('uploadArea');
    var fileInput = document.getElementById('fileInput');
    var imageInput = document.getElementById('imageInput');
    var imagePreview = document.getElementById('imagePreview');
    var uploadPlaceholder = document.getElementById('uploadPlaceholder');
    var uploadOverlay = document.getElementById('uploadOverlay');
    var imageActions = document.getElementById('imageActions');
    var uploadProgress = document.getElementById('uploadProgress');
    var uploadProgressBar = document.getElementById('uploadProgressBar');

    uploadArea.addEventListener('click', function() { fileInput.click(); });

    uploadArea.addEventListener('dragover', function(e) {
        e.preventDefault();
        uploadArea.classList.add('dragover');
    });
    uploadArea.addEventListener('dragleave', function() {
        uploadArea.classList.remove('dragover');
    });
    uploadArea.addEventListener('drop', function(e) {
        e.preventDefault();
        uploadArea.classList.remove('dragover');
        if (e.dataTransfer.files.length > 0) {
            uploadFile(e.dataTransfer.files[0]);
        }
    });

    fileInput.addEventListener('change', function() {
        if (this.files.length > 0) uploadFile(this.files[0]);
    });

    document.getElementById('removeImageBtn').addEventListener('click', function(e) {
        e.stopPropagation();
        imageInput.value = '';
        imagePreview.style.display = 'none';
        imagePreview.src = '';
        uploadOverlay.style.display = 'none';
        if (uploadPlaceholder) uploadPlaceholder.style.display = '';
        imageActions.style.display = 'none';
    });

    function uploadFile(file) {
        if (!file.type.startsWith('image/')) {
            showToast('只允许上传图片文件', 'error');
            return;
        }
        if (file.size > 5 * 1024 * 1024) {
            showToast('文件大小不能超过5MB', 'error');
            return;
        }

        var formData = new FormData();
        formData.append('file', file);

        uploadProgress.style.display = 'block';
        uploadProgressBar.style.width = '0%';

        var xhr = new XMLHttpRequest();
        xhr.open('POST', contextPath + '/admin/upload', true);

        xhr.upload.addEventListener('progress', function(e) {
            if (e.lengthComputable) {
                uploadProgressBar.style.width = Math.round(e.loaded / e.total * 100) + '%';
            }
        });

        xhr.onload = function() {
            uploadProgress.style.display = 'none';
            try {
                var resp = JSON.parse(xhr.responseText);
                if (resp.success) {
                    imageInput.value = resp.url;
                    imagePreview.src = contextPath + resp.url;
                    imagePreview.style.display = 'block';
                    uploadOverlay.style.display = '';
                    if (uploadPlaceholder) uploadPlaceholder.style.display = 'none';
                    imageActions.style.display = 'flex';
                    showToast('图片上传成功', 'success');
                } else {
                    showToast(resp.message || '上传失败', 'error');
                }
            } catch (e) {
                showToast('上传失败', 'error');
            }
        };

        xhr.onerror = function() {
            uploadProgress.style.display = 'none';
            showToast('网络错误，上传失败', 'error');
        };

        xhr.send(formData);
    }
})();

$('#productForm').on('submit', function(e) {
    e.preventDefault();
    var valid = validateForm('productForm', {
        name: { required: true, requiredMsg: '请输入商品名称' },
        price: { required: true, requiredMsg: '请输入价格' },
        stock: { required: true, requiredMsg: '请输入库存' }
    });
    if (!valid) return;

    ajaxPost(contextPath + '/admin/product/save', $(this).serialize(), function(resp) {
        if (resp.success) {
            showToast(resp.message, 'success');
            setTimeout(function() { window.location.href = contextPath + '/admin/products'; }, 800);
        } else {
            showToast(resp.message, 'error');
            if (resp.field) highlightField(resp.field);
        }
    });
});
</script>
