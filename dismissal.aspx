<%@ Page Title="" Language="C#" MasterPageFile="~/Pages/SEM/semMaster.Master" AutoEventWireup="true" CodeBehind="dismissal.aspx.cs" Inherits="WebSite.Pages.SEM.dismissal" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <link href="css/jquery.auto-complete.css" rel="stylesheet" />
    <script src="js/jquery.auto-complete.js" type="text/javascript"></script>
    <style type="text/css">
        .box-container {
            min-height: 500px;
        }

            .box-container .form-content {
                border: 1px solid #bdb5b5;
                border-radius: 6px;
                padding: 12px;
                min-height: 290px;
            }

        .displayBlock {
            display: block !important;
        }

        .displayNone {
            display: none !important;
        }

        .btn-lg {
            margin-top: 145px;
        }

        .nomargin {
            margin-top: 0px !important;
        }

        input, .autocomplete-suggestion {
            font-weight: 600;
        }
    </style>

    <script type="text/javascript">
        $(document).ready(function () {
            if (!$("#<%= panelSelectSchool.ClientID %>").hasClass("displayNone"))
                LoadSchools();
            if (!$("#<%= panelSelectParent.ClientID %>").hasClass("displayNone"))
                LoadParents();
        });

        function LoadParents() {
            var schoolid = $("#<%= hdnSelectedSchoolId.ClientID %>").val();

            var schoolParentCount = 0;
            $.ajax({
                type: "POST",
                contentType: "application/json; charset=utf-8",
                url: "dismissal.aspx/SchoolParentCount",
                data: "{schoolid:'" + schoolid + "'}",
                dataType: "json",
                success: function (output) {
                    schoolParentCount = JSON.parse(output.d);
                    $("#<%= hdnParentCount.ClientID%>").val(schoolParentCount);

                    // if school does not have parent then show take picture panel
                    if (schoolParentCount == 0) {
                        ShowPanelJ($("#<%= panelSelectParentPicture.ClientID %>"));
                        TakeParentPhoto();
                    }
                    else //otherwise show parents name picklist to select
                    {
                        $("#<%= txtParentName.ClientID %>").autoComplete({
                            minChars: 0,
                            source: function (request, response) {
                                $.ajax({
                                    type: "POST",
                                    contentType: "application/json; charset=utf-8",
                                    url: "dismissal.aspx/GetParents",
                                    data: "{term:'" + request + "',schoolid:'" + schoolid + "'}",
                                    dataType: "json",
                                    success: function (output) {
                                        response($.map(JSON.parse(output.d), function (item) {
                                            return {
                                                label: item.Text,
                                                value: item.Value
                                            };
                                        }));
                                    },
                                    error: function (errormsg) {
                                        console.log(errormsg.responseText);
                                    }
                                });
                            },
                            renderItem: function (item, search) {
                                search = search.replace(/[-\/\\^$*+?.()|[\]{}]/g, '\\$&');
                                var re = new RegExp("(" + search.split(' ').join('|') + ")", "gi");
                                return '<div class="autocomplete-suggestion" data-label="' + item.label + '" data-val="' + item.value + '">' + item.label + '</div>';
                            },
                            onSelect: function (event, ui, item) {
                                event.preventDefault();
                                $("#<%= txtParentName.ClientID %>").val(item.data('label'));
                                $("#<%= hdnSelectedParentId.ClientID %>").val(item.data('val'));

                                ShowPanelJ($("#<%= panelSelectParentPicture.ClientID %>"));
                                TakeParentPhoto();
                            }
                        });

                        $("#<%= txtParentName.ClientID %>").focus();
                        $("#<%= txtParentName.ClientID %>").on('focus', function () {
                            $(this).trigger('keyup');
                        });
                    }

                },
                error: function (errormsg) {
                    console.log(errormsg.responseText);
                }
            });
        }


        function LoadSchools() {
            $("#<%= txtSchool.ClientID %>").autoComplete({
                minChars: 0,
                source: function (request, response) {
                    $.ajax({
                        type: "POST",
                        contentType: "application/json; charset=utf-8",
                        url: "dismissal.aspx/GetSchools",
                        data: "{term:'" + request + "'}",
                        dataType: "json",
                        success: function (output) {
                            response($.map(JSON.parse(output.d), function (item) {
                                return {
                                    label: item.Text,
                                    value: item.Value
                                };
                            }));
                        },
                        error: function (errormsg) {
                            console.log(errormsg.responseText);
                        }
                    });
                },
                renderItem: function (item, search) {
                    search = search.replace(/[-\/\\^$*+?.()|[\]{}]/g, '\\$&');
                    var re = new RegExp("(" + search.split(' ').join('|') + ")", "gi");
                    return '<div class="autocomplete-suggestion" data-label="' + item.label + '" data-val="' + item.value + '">' + item.label + '</div>';
                },
                onSelect: function (event, ui, item) {
                    event.preventDefault();
                    $("#<%= txtSchool.ClientID %>").val(item.data('label'));
                    $("#<%= hdnSelectedSchoolId.ClientID %>").val(item.data('val'));


                    ShowPanelJ($("#<%= panelSelectParent.ClientID %>"));
                    $("#<%= lblSelectedSchool.ClientID %>").text(item.data('label'));
                    $("#<%= lblSelectedSchool.ClientID %>").attr('class', 'selected-school displayBlock');
                    LoadParents();
                }
            });

            $("#<%= txtSchool.ClientID %>").focus();
            $("#<%= txtSchool.ClientID %>").on('focus', function () {
                $(this).trigger('keyup');
            });
        }

        function LoadStudents() {
            var schoolid = $("#<%= hdnSelectedSchoolId.ClientID %>").val();
            $("#<%= txtStudentNames.ClientID %>").val("");
            $("#<%= txtStudentNames.ClientID %>").autoComplete({
                minChars: 0,
                source: function (request, response) {
                    $.ajax({
                        type: "POST",
                        contentType: "application/json; charset=utf-8",
                        url: "dismissal.aspx/GetStudents",
                        data: "{term:'" + request + "',schoolid:'" + schoolid + "'}",
                        dataType: "json",
                        success: function (output) {
                            if (JSON.parse(output.d) == "") {
                                <%-- $("#<%= txtStudentNames.ClientID %>").hide();
                                $("#<%= lblSelectStudentPicklist.ClientID %>").hide();                                
                                $("#<%= lblNoStudentsPicklist.ClientID %>").removeClass("displayNone");
                                $("#<%= lblNoStudentsPicklist.ClientID %>").addClass("displayBlock");--%>
                            }
                            else {
                                response($.map(JSON.parse(output.d), function (item) {
                                    return {
                                        label: item.Name,
                                        value: item.ID
                                    };
                                }));
                            }
                        },
                        error: function (errormsg) {
                            console.log(errormsg.responseText);
                        }
                    });
                },
                renderItem: function (item, search) {
                    search = search.replace(/[-\/\\^$*+?.()|[\]{}]/g, '\\$&');
                    var re = new RegExp("(" + search.split(' ').join('|') + ")", "gi");
                    return '<div class="autocomplete-suggestion" data-label="' + item.label + '" data-val="' + item.value + '">' + item.label + '</div>';
                },
                onSelect: function (event, ui, item) {
                    event.preventDefault();
                    $("#<%= txtStudentNames.ClientID %>").val(item.data('label'));
                    $("#<%= hdnSelectedStudentId.ClientID %>").val(item.data('val'));
                }
            });

            $("#<%= txtStudentNames.ClientID %>").focus();
            $("#<%= txtStudentNames.ClientID %>").on('focus', function () {
                $(this).trigger('keyup');
            });
        }

        function ShowPanelJ(PANEL_TO_SHOW) {
            $("#<%= panelSelectSchool.ClientID %>").attr('class', 'displayNone');
            $("#<%= panelSelectParent.ClientID %>").attr('class', 'displayNone');

            $(PANEL_TO_SHOW).attr('class', '');
            $(PANEL_TO_SHOW).addClass("displayBlock");
        }

        function CheckSchool() {
            if ($("#<%= hdnSelectedSchoolId.ClientID %>").val() == "" || $("#<%= txtSchool.ClientID %>").val() == "") {
                $.alert({
                    title: 'Error!',
                    content: 'Please select a school to proceed!',
                    type: 'red',
                    buttons: {
                        Ok: {
                            text: 'Ok',
                            btnClass: 'btn-red'
                        }
                    }
                });
                return false;
            }
            return true;
        }

        function CheckParent() {
            if ($("#<%= hdnSelectedParentId.ClientID %>").val() == "" || $("#<%= txtParentName.ClientID %>").val() == "") {
                $.alert({
                    title: 'Error!',
                    content: 'Please select parent name to proceed!',
                    type: 'red',
                    buttons: {
                        Ok: {
                            text: 'Ok',
                            btnClass: 'btn-red'
                        }
                    }
                });
                return false;
            }
            return true;
        }

        function CheckParentPhoto() {
            var parentCount = $("#<%= hdnParentCount.ClientID%>").val();
            var parentPhoto = $("#<%= hdnParentPhoto.ClientID%>").val();

            //if school does not have parent then take parent photo is mandatory
            if (parentPhoto == "" && ($("#<%= hdnSelectedParentId.ClientID %>").val() == "" || $("#<%= txtParentName.ClientID %>").val() == "")) {
                $.alert({
                    title: 'Error!',
                    content: 'Please take parent picture!',
                    type: 'red',
                    buttons: {
                        Ok: {
                            text: 'Ok',
                            btnClass: 'btn-red'
                        }
                    }
                });
                return false;
            }

            return true;
        }

        function CheckStudent() {
            var a = $("input[id^='<%= chkLstStudents.ClientID %>']:checkbox:checked");

            if ($(a).length <= 0) {
                $.alert({
                    title: 'Error!',
                    content: 'Please select a student from the list to proceed!',
                    type: 'red',
                    buttons: {
                        Ok: {
                            text: 'Ok',
                            btnClass: 'btn-red'
                        }
                    }
                });
                return false;
            }
            return true;
        }

        function CheckStudentPicklist() {
            if ($("#<%= hdnSelectedStudentId.ClientID %>").val() == "" || $("#<%= txtStudentNames.ClientID %>").val() == "") {
                $.alert({
                    title: 'Error!',
                    content: 'Please select student name to proceed!',
                    type: 'red',
                    buttons: {
                        Ok: {
                            text: 'Ok',
                            btnClass: 'btn-red'
                        }
                    }
                });
                return false;
            }
            return true;
        }

        function TakeParentPhoto() {

            $("html, body").animate({ scrollTop: 0 }, "slow");
            //parent photo
            var video = document.getElementById('video');
            if (navigator.mediaDevices && navigator.mediaDevices.getUserMedia) {
                navigator.mediaDevices.getUserMedia({ video: { facingMode: "environment" } }).then(function (stream) {
                    //video.src = window.URL.createObjectURL(stream);
                    video.srcObject = stream;
                    video.play();
                });
            }
            var canvas = document.getElementById('canvas');
            var context = canvas.getContext('2d');

            if ($("#<%= hdnParentPhoto.ClientID %>").val() != "") {
                var image = new Image();
                image.onload = function () {
                    context.drawImage(image, 0, 0, 270, 350);
                };
                image.src = "data:image/jpg;base64," + $("#<%= hdnParentPhoto.ClientID %>").val();
            }

            document.getElementById("snap").addEventListener("click", function () {
                context.drawImage(video, 0, 0, 270, 350);
                var mydataURL = canvas.toDataURL('image/jpg');
                var myBase64Data = mydataURL.split(',')[1];
                $("#<%= hdnParentPhoto.ClientID %>").val(myBase64Data);
                $("#<%= hdnPhotoName.ClientID %>").val("");                
            });
        }

        function TakeParentIdPhoto() {
            $("html, body").animate({ scrollTop: 0 }, "slow");
            //parent id photo
            var videoPId = document.getElementById('videoPId');

            if (navigator.mediaDevices && navigator.mediaDevices.getUserMedia) {
                navigator.mediaDevices.getUserMedia({ video: { facingMode: "environment" } }).then(function (stream) {
                    //videoPId.src = window.URL.createObjectURL(stream);
                    videoPId.srcObject = stream;
                    videoPId.play();
                });
            }

            var canvasPId = document.getElementById('canvasPId');
            var contextPId = canvasPId.getContext('2d');

            if ($("#<%= hdnParentIdPhoto.ClientID %>").val() != "") {
                var image = new Image();
                image.onload = function () {
                    contextPId.drawImage(image, 0, 0, 270, 350);
                };
                image.src = "data:image/jpg;base64," + $("#<%= hdnParentIdPhoto.ClientID %>").val();
            }

            document.getElementById("snapPId").addEventListener("click", function () {
                contextPId.drawImage(videoPId, 0, 0, 270, 350);
                var mydataURL = canvasPId.toDataURL('image/jpg');
                var myBase64Data = mydataURL.split(',')[1];
                $("#<%= hdnParentIdPhoto.ClientID %>").val(myBase64Data);
            });
        }

    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

    <section class="main-content">
    <asp:UpdatePanel runat="server" ID="updatePanelDismissal">
        <ContentTemplate>
            <asp:HiddenField ID="hdnParentCount" runat="server" />
           <%-- <asp:HiddenField ID="hdnImgName" runat="server" />--%>

            <asp:Panel runat="server" ID="panelSelectSchool">
                <div class="section-title">
                    <h3>
                        <asp:Label runat="server">Select School</asp:Label>
                    </h3>
                </div>
                <div class="form-content">
                    <div class="row">
                        <div class="form-group col-md-12">
                            <asp:TextBox runat="server" ID="txtSchool" CssClass="form-control" placeholder="Please select school"></asp:TextBox>
                            <asp:HiddenField ID="hdnSelectedSchoolId" runat="server" />
                        </div>
                    </div>
                    <div class="row">
                        <div class="form-group col-md-8">
                        </div>
                        <div class="form-group col-md-4">
                            <asp:Button CssClass="btn btn-lg btn-red" OnClientClick="return CheckSchool();" ID="btnNextSelectSchool" Text="Next" runat="server" OnClick="btnNextSelectSchool_Click" />
                        </div>
                    </div>
                </div>
            </asp:Panel>

            <div class="row">
                <div class="form-group col-md-12">
                    <asp:Label runat="server" ID="lblSelectedSchool" CssClass="selected-school"></asp:Label>
                </div>
            </div>

            <asp:Panel runat="server" ID="panelSelectParent">
                <div class="section-title">
                    <h3>
                        <asp:Label runat="server">Select Parent</asp:Label>
                    </h3>
                </div>
                <div class="form-content">
                    <div class="row">
                        <div class="form-group col-md-12">
                            <asp:TextBox runat="server" ID="txtParentName" CssClass="form-control" placeholder="Please select parent name"></asp:TextBox>
                            <asp:HiddenField ID="hdnSelectedParentId" runat="server" />
                        </div>
                    </div>
                    <div class="row" style="margin-top: 50px">
                        <div class="form-group col-md-6">
                        </div>
                        <div class="form-group col-md-6">
                            <asp:Button CssClass="btn btn-lg btn-default" ID="btnBackSelectParent" Text="Back" runat="server" OnClick="btnBackSelectParent_Click" />
                            <asp:Button CssClass="btn btn-lg btn-red" ID="btnNextSelectParent" Text="Next" runat="server" OnClick="btnNextSelectParent_Click" /> <%--OnClientClick="return CheckParent();"--%>
                        </div>
                        
                    </div>
                </div>
            </asp:Panel>

            <asp:Panel runat="server" ID="panelSelectParentPicture">
                <div class="section-title">
                    <h3>
                        <asp:Label runat="server">Take Parent's Picture</asp:Label>
                    </h3>
                </div>
                <div class="form-content">
                    <div class="row">
                        <div class="form-group col-md-6">
                            <video id="video" width="270" autoplay></video>    
                          </div>
                          <div class="form-group col-md-6">   
                               <input type="button" id="snap" value="Snap Photo" class="btn btn-lg nomargin" />
                           </div>                           
                        </div>
                     <div class="row">
                         <div class="form-group col-md-6">                               
                         <canvas id="canvas" width="270" height="350"></canvas>
                               <asp:HiddenField id="hdnParentPhoto" runat="server" />  
                              <asp:HiddenField id="hdnPhotoName" runat="server" />            
                        </div>
                         
                        <div class="form-group col-md-6">                            
                           <asp:Button CssClass="btn btn-lg btn-default nomargin" ID="btnBackParentPicture" Text="Back" runat="server" OnClick="btnBackParentPicture_Click" />
                            <asp:Button CssClass="btn btn-lg btn-red nomargin" ID="btnNextParentPicture" OnClientClick="return CheckParentPhoto();" Text="Next" runat="server" OnClick="btnNextParentPicture_Click" />
                        </div>                      
                    </div>
                    </div>
            </asp:Panel>

            <asp:Panel runat="server" ID="panelTakeParentIdPicture">
                <div class="section-title">
                    <h3>
                        <asp:Label runat="server">Take Parent Id's Picture</asp:Label>
                    </h3>
                </div>
                  <div class="form-content">
                    <div class="row">
                        <div class="form-group col-md-6">
                            <video id="videoPId" width="270" autoplay></video> 
                          </div>
                          <div class="form-group col-md-6">      
                                <input type="button" id="snapPId" value="Snap Photo" class="btn btn-lg nomargin" />                
                        
                           </div>                           
                        </div>
                     <div class="row">
                         <div class="form-group col-md-6">                               
                         <canvas id="canvasPId" width="270" height="350"></canvas>
                               <asp:HiddenField id="hdnParentIdPhoto" runat="server" />
                          </div>                         
                        <div class="form-group col-md-6">                            
                            <asp:Button CssClass="btn btn-lg btn-default nomargin" ID="btnBackParentIdPicture" Text="Back" runat="server" OnClick="btnBackParentIdPicture_Click" />
                            <asp:Button CssClass="btn btn-lg btn-red nomargin" ID="btnNextParentIdPicture" Text="Next" runat="server" OnClick="btnNextParentIdPicture_Click" />
                        </div>                      
                    </div>
                    </div>
            </asp:Panel>

            <asp:Panel runat="server" ID="panelSelectStudent">
                <div class="section-title">
                    <h3>
                        <asp:Label ID="lblSelectStudent" runat="server">Select Student</asp:Label>
                    </h3>
                </div>
                <div class="form-content">
                    <div class="row">
                        <div class="form-group col-md-12">
                           <asp:CheckBoxList runat="server" CssClass="chkboxlst" ID="chkLstStudents"></asp:CheckBoxList>
                            <asp:Label runat="server" ID="lblNoStudent" Visible="false" ForeColor="Red" Text="No students found to dismiss for the selected parent and school!"></asp:Label>
                        </div>
                    </div>
                    <div class="row" style="margin-top: 50px">
                        <div class="form-group col-md-4">
                        </div>
                        <div class="form-group col-md-8">
                            <asp:Button CssClass="btn btn-lg btn-red nomargin" ID="Button1" Text="Cancel" runat="server" OnClick="btnNewDismissal_Click" />
                            <asp:Button CssClass="btn btn-lg btn-default nomargin" ID="btnBackSelectStudent" Text="Back" runat="server" OnClick="btnBackSelectStudent_Click"/>
                            <asp:Button CssClass="btn btn-lg btn-blue nomargin" ID="btnDone" OnClientClick="return CheckStudent();" Text="Done" runat="server" OnClick="btnDone_Click"/>
                        </div>                       
                    </div>
                </div>
            </asp:Panel>


            <asp:Panel runat="server" ID="panelStudentsPicklist">
                <div class="section-title">
                    <h3>
                        <asp:Label ID="lblSelectStudentPicklist" runat="server">Select Student</asp:Label>
                    </h3>
                </div>
                <div class="form-content">
                    <div class="row">
                        <div class="form-group col-md-12">
                            <asp:TextBox runat="server" ID="txtStudentNames" CssClass="form-control" placeholder="Please select student name"></asp:TextBox>
                            <asp:HiddenField ID="hdnSelectedStudentId" runat="server" />
                            <asp:Label runat="server" ID="lblNoStudentsPicklist" CssClass="displayNone" ForeColor="Red" Text="No students found to dismiss for the selected parent and school!"></asp:Label>
                        </div>
                    </div>
                    <div class="row">
                        <div class="form-group col-md-4">
                        </div>
                        <div class="form-group col-md-8">
                             <asp:Button CssClass="btn btn-lg btn-red" ID="btnCancelPicklist" Text="Cancel" runat="server" OnClick="btnNewDismissal_Click" />
                           <asp:Button CssClass="btn btn-lg btn-default" ID="btnBackStudentPicklist" Text="Back" runat="server" OnClick="btnBackSelectStudent_Click" />
                            <asp:Button CssClass="btn btn-lg btn-blue" ID="BtnDoneStudentPicklist" OnClientClick="return CheckStudentPicklist();" Text="Done" runat="server" OnClick="btnDone_Click" />
                        </div>
                    </div>
                </div>
            </asp:Panel>

            <asp:Panel runat="server" ID="panelDismissToSameParent">
                <div class="form-content">
                    <div class="row">
                        <div class="form-group col-md-12">
                           <asp:Button CssClass="btn btn-lg btn-default" ID="btnDismissToSameAdult" Text="Dismiss Another Student to Same Adult" runat="server" OnClick="btnDismissToSameAdult_Click" />
                           <asp:Button CssClass="btn btn-lg btn-blue" ID="btnNewDismissal" Text="New Dismissal" runat="server" OnClick="btnNewDismissal_Click" />
                        </div>
                    </div>
                </div>
            </asp:Panel>

        </ContentTemplate>
    </asp:UpdatePanel>

</section>
    <script type="text/javascript">

       
    </script>
</asp:Content>
