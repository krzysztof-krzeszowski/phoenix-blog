import {Socket} from "phoenix"

import $ from "jquery";

const userToken = $("meta[name='channel_token']").attr("content")
const socket = new Socket("/socket", {params: {token: userToken}})

socket.connect()

const CREATED_COMMENT = "CREATED_COMMENT"
const APPROVED_COMMENT = "APPROVED_COMMENT"
const DELETED_COMMENT = "DELETED_COMMENT"

const postId = $("#post-id").val();
const channel = socket.channel(`comments:${postId}`, {});
channel.join()
  .receive("ok", resp => { console.log("Joined successfully", resp) })
  .receive("error", resp => { console.log("Unable to join", resp) });

const createComment = (payload) => `
    <div id="comment-${payload.commentId}" class="comment" data-comment-id="${payload.commentId}">
        <div class="row">
            <div class="col-xs-4">
                <strong class="comment-author">${payload.author}</strong>
            </div>
            <div class="col-xs-4">
                <em>${payload.insertedAt}</em>
            </div>
            <div class="col-xs-4 text-right">
                ${userToken ? '<button class="btn btn-xs btn-primary approve">Approve</button><button class="btn btn-xs btn-danger delete">Delete</button>' : ''}
            </div>
        </div>
        <div class="row">
            <div class="col-xs-12 comment-body">
                ${payload.body}
            </div>
        </div>
    </div>
`

const getCommentAuthor = () => $("#comment_author").val()
const getCommentBody = () => $("#comment_body").val()
const getTargetCommentId = (target) => $(target).parents(".comment").data("comment-id")

const resetFields = () => {
    $("#comment_author").val("")
    $("#comment_body").val("")
}

$(".create_comment").on("click", (event) => {
    event.preventDefault()
    channel.push(CREATED_COMMENT, {author: getCommentAuthor(), body: getCommentBody(), postId})
    resetFields()
})

$(".comments").on("click", ".approve", (event) => {
    event.preventDefault()
    const commentId = getTargetCommentId(event.currentTarget)
    const author = $(`#comment-${commentId} .comment-author`).text().trim()
    const body = $(`#comment-${commentId} .comment-body`).text().trim()
    channel.push(APPROVED_COMMENT, {author, body, commentId, postId})
})

$(".comments").on("click", ".delete", (event) => {
    event.preventDefault()
    const commentId = getTargetCommentId(event.currentTarget)
    channel.push(DELETED_COMMENT, {commentId, postId})
})

channel.on(CREATED_COMMENT, (payload) => {
    if (!userToken && !payload.approved) {return;}
    $(".comments h2").after(
        createComment(payload)
    )
});

channel.on(APPROVED_COMMENT, (payload) => {
    if ($(`#comment-${payload.commentId}`).length === 0) {
        $(".comments h2").after(
            createComment(payload)
        )
    }
    $(`#comment-${payload.commentId} .approve`).remove()
});

channel.on(DELETED_COMMENT, (payload) => {
    $(`#comment-${payload.commentId}`).remove()
});

$("input[type=submit]").on("click", (event) => {
    event.preventDefault();
    channel.push(CREATED_COMMENT, {author: "test", body: "body"});
});

export default socket
