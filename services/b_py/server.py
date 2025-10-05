import grpc
from concurrent import futures
import time, os

from proto import services_pb2, services_pb2_grpc

class ServiceBImpl(services_pb2_grpc.ServiceBServicer):
    def StreamNumbers(self, request, context):
        count = request.count if request.count > 0 else 5
        delay_ms = request.delay_ms if request.delay_ms > 0 else 0
        for i in range(1, count + 1):
            yield services_pb2.NumberReply(value=i)
            if delay_ms > 0:
                time.sleep(delay_ms/1000.0)

def serve():
    port = int(os.environ.get("PORT", "50052"))
    server = grpc.server(futures.ThreadPoolExecutor(max_workers=10))
    services_pb2_grpc.add_ServiceBServicer_to_server(ServiceBImpl(), server)
    server.add_insecure_port(f"[::]:{port}")
    server.start()
    print(f"Service B listening on :{port}", flush=True)
    try:
        while True:
            time.sleep(86400)
    except KeyboardInterrupt:
        server.stop(0)

if __name__ == "__main__":
    serve()
