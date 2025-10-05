import grpc
from concurrent import futures
import time, os

from proto import services_pb2, services_pb2_grpc

class ServiceAImpl(services_pb2_grpc.ServiceAServicer):
    def SayHello(self, request, context):
        name = request.name or "world"
        return services_pb2.HelloReply(message=f"Olá, {name}! [A]")

def serve():
    port = int(os.environ.get("PORT", "50051"))
    server = grpc.server(futures.ThreadPoolExecutor(max_workers=10))
    services_pb2_grpc.add_ServiceAServicer_to_server(ServiceAImpl(), server)
    server.add_insecure_port(f"[::]:{port}")
    server.start()
    print(f"Service A listening on :{port}", flush=True)
    try:
        while True:
            time.sleep(86400)
    except KeyboardInterrupt:
        server.stop(0)

if __name__ == "__main__":
    serve()
