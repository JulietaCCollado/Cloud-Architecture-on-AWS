exports.handler = async (event) => {
    const response = {
        statusCode: 200,
        headers: {
            "Content-Type": "text/html"
        },
        body: "<h1>Hello Professor!</h1>"
    };
    return response;
};
